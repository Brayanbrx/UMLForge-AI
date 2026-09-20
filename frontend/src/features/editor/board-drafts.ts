import type { CommandBatch } from '@uml/contracts';
import { applyBatchToDocument, readBoardState } from '@uml/yjs-adapter';
import * as Y from 'yjs';

/** A separate slot per mounted editor avoids overwriting another tab's offline work. */
export class BoardDrafts {
  private readonly prefix: string;
  private readonly key: string;
  private readonly snapshotKey: string;

  constructor(
    private readonly storage: Storage,
    userId: string,
    room: string,
  ) {
    this.prefix = `uml_board_draft_v1:${encodeURIComponent(userId)}:${encodeURIComponent(room)}:`;
    this.key = this.prefix + crypto.randomUUID();
    this.snapshotKey = `uml_board_snapshot_v1:${encodeURIComponent(userId)}:${encodeURIComponent(room)}`;
  }

  /** Last authorized server state, also saved for readers and untouched boards. */
  snapshot(doc: Y.Doc): void {
    this.storage.setItem(this.snapshotKey, encode(doc));
  }

  /** Offline replicas never go directly into a provider; reconnect starts clean. */
  openOffline(doc: Y.Doc, includeDrafts: boolean): boolean {
    const value = this.storage.getItem(this.snapshotKey);
    if (value === null) return false;
    const candidate = new Y.Doc();
    try {
      Y.applyUpdate(candidate, decode(value));
      if (includeDrafts) this.restore(candidate);
      readBoardState(candidate);
      Y.applyUpdate(doc, Y.encodeStateAsUpdate(candidate));
      return true;
    } finally {
      candidate.destroy();
    }
  }

  /** On a live replica, call only after server write authorization and initial sync. */
  restore(doc: Y.Doc): boolean {
    const entries = this.entries();
    if (entries.length === 0) return false;
    const candidate = new Y.Doc();
    try {
      Y.applyUpdate(candidate, Y.encodeStateAsUpdate(doc));
      for (const [, value] of entries) {
        Y.applyUpdate(candidate, decode(value));
      }
      readBoardState(candidate);
      // Persist the merged copy before deleting old slots or modifying the editor.
      this.save(candidate, entries);
      Y.applyUpdate(doc, Y.encodeStateAsUpdate(candidate));
      return true;
    } finally {
      candidate.destroy();
    }
  }

  /** Commit to local storage before publishing: quota/privacy failures cannot lose a change. */
  apply(doc: Y.Doc, batch: CommandBatch): ReturnType<typeof applyBatchToDocument> {
    const candidate = new Y.Doc();
    try {
      Y.applyUpdate(candidate, Y.encodeStateAsUpdate(doc));
      const result = applyBatchToDocument(candidate, batch);
      if (!result.applied) return result;
      this.save(candidate, []);
      Y.applyUpdate(doc, Y.encodeStateAsUpdate(candidate));
      return result;
    } finally {
      candidate.destroy();
    }
  }

  private entries(): [string, string][] {
    const entries: [string, string][] = [];
    for (let i = 0; i < this.storage.length; i += 1) {
      const key = this.storage.key(i);
      if (key?.startsWith(this.prefix)) {
        const value = this.storage.getItem(key);
        if (value !== null) entries.push([key, value]);
      }
    }
    return entries;
  }

  private save(doc: Y.Doc, previous: [string, string][]): void {
    this.storage.setItem(this.key, encode(doc));
    for (const [key, value] of previous) {
      // Another tab may have updated its slot since we read it.
      if (key !== this.key && this.storage.getItem(key) === value) this.storage.removeItem(key);
    }
  }
}

function encode(doc: Y.Doc): string {
  const bytes = Y.encodeStateAsUpdate(doc);
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

function decode(value: string): Uint8Array {
  return Uint8Array.from(atob(value), (char) => char.charCodeAt(0));
}
