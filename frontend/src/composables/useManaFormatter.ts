// MTG Mana symbols mapping to Scryfall symbol codes
// Maps parsed symbol text to the code used in Scryfall CDN URLs
const manaSymbolMap: Record<string, string> = {
  // Generic/Colorless
  '0': '0', '1': '1', '2': '2', '3': '3', '4': '4',
  '5': '5', '6': '6', '7': '7', '8': '8', '9': '9',
  '10': '10', '11': '11', '12': '12', '13': '13', '14': '14',
  '15': '15', '16': '16', '17': '17', '18': '18', '19': '19',
  '20': '20', '100': '100', '1000000': '1000000',
  // Mana colors
  'w': 'W', 'u': 'U', 'b': 'B', 'r': 'R', 'g': 'G', 'c': 'C', 's': 'S',
  // Variable mana
  'x': 'X', 'y': 'Y', 'z': 'Z',
  // Special action symbols
  't': 'T', 'q': 'Q', 'e': 'E',
  // Phyrexian
  'p': 'P', 'pw': 'PW', 'pu': 'PU', 'pb': 'PB', 'pr': 'PR', 'pg': 'PG', 'pc': 'PC',
  // Hybrid mana (two colors)
  'w/u': 'WU', 'w/b': 'WB', 'u/b': 'UB', 'u/r': 'UR', 'b/r': 'BR', 'b/g': 'BG', 'r/g': 'RG', 'r/w': 'RW', 'g/w': 'GW', 'g/u': 'GU',
  // Phyrexian hybrid
  'w/p': 'WP', 'u/p': 'UP', 'b/p': 'BP', 'r/p': 'RP', 'g/p': 'GP', 'c/p': 'CP',
  'w/u/p': 'WUP', 'u/b/p': 'UBP', 'b/r/p': 'BRP', 'r/g/p': 'RGP', 'g/w/p': 'GWP', 'u/r/p': 'URP', 'w/b/p': 'WBP', 'b/g/p': 'BGP', 'r/w/p': 'RWP', 'g/u/p': 'GUP',
  // Generic or color hybrid
  '2/w': '2W', '2/u': '2U', '2/b': '2B', '2/r': '2R', '2/g': '2G',
  'c/w': 'CW', 'c/u': 'CU', 'c/b': 'CB', 'c/r': 'CR', 'c/g': 'CG',
  // Half mana
  'hw': 'HW', 'hr': 'HR', 'half': 'HALF',
  // Other
  'h': 'H', 'l': 'L', 'd': 'D',
}

const getScryfallIconUrl = (symbol: string): string => {
  return `https://svgs.scryfall.io/card-symbols/${symbol}.svg`
}

export const useManaFormatter = () => {
  const formatMana = (manaCost: string): Array<{ text: string; iconUrl: string }> => {
    if (!manaCost) return []
    
    const manaRegex = /{[^}]+}/g
    const matches = manaCost.match(manaRegex) || []
    
    return matches.map(match => {
      const originalSymbol = match.slice(1, -1) // Remove curly braces
      const normalizedSymbol = originalSymbol.toLowerCase()
      const scryfallCode = manaSymbolMap[normalizedSymbol] || originalSymbol.toUpperCase()
      
      return {
        text: originalSymbol,
        iconUrl: getScryfallIconUrl(scryfallCode)
      }
    })
  }

  return { formatMana }
}
