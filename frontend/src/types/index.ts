export interface Card {
  id?: number;
  name: string;
  set: string;
  set_code?: string;
  price: number;
  image_uri: string;
  mana_cost?: string;
  type_line?: string;
  oracle_text?: string;
  scryfall_uri?: string;
  added_date?: string;
  found?: boolean;  // Used in scan/identify responses to indicate if card was found
}

export interface Prices {
  usd?: number;
  usd_foil?: number;
  eur?: number;
  eur_foil?: number;
  tix?: number;
}

export interface SearchResult {
  name: string;
  set: string;
  set_code: string;
  mana_cost: string;
  type_line: string;
  oracle_text: string;
  prices: Prices;
  image_uri: string;
  scryfall_uri: string;
}

export interface Stats {
  total_cards: number;
  total_value: number;
  ocr_available: boolean;
}

export interface ScanResult {
  num_detected: number;
  cards: Card[];
  filename?: string;
  message?: string;
}

export interface IdentifyResult {
  cards: Card[];
  total_value: number;
}

export interface CollectionExport {
  exported_date: string;
  total_cards: number;
  total_value: number;
  cards: Card[];
}

export interface ApiResponse<T = any> {
  success?: boolean;
  error?: string;
  data?: T;
}
