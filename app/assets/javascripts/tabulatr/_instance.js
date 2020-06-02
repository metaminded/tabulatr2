class TabulatrInstances {
  constructor() {
    if (TabulatrInstances.INSTANCE) {
      throw new Error('TabulatrInstances is already initialized');
    }
    
    this._ids = [];
    this._tables = {};
  }

  static get instance() {
    if (!TabulatrInstances.INSTANCE) {
      TabulatrInstances.INSTANCE = new TabulatrInstances();
    }
    return TabulatrInstances.INSTANCE;
  }

  table(id) {
    if(!id)
      throw new Error('trying to get a table by an undefined id');
    if(!(id in this._tables)) {
      this._ids.push(id);
      this._tables[id] = new TabulatrTable(id);
    }
    return this._tables[id];
  }

  get ids() {
    return this._ids;
  }
}

TabulatrInstances.INSTANCE = undefined;
