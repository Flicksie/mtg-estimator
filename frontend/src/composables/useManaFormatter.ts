// MTG Mana icons mapping using Unicode symbols and FontAwesome
const manaIcons: Record<string, { icon: string; color: string }> = {
  '{0}': { icon: '⓪', color: '#999' },
  '{1}': { icon: '①', color: '#999' },
  '{2}': { icon: '②', color: '#999' },
  '{3}': { icon: '③', color: '#999' },
  '{4}': { icon: '④', color: '#999' },
  '{5}': { icon: '⑤', color: '#999' },
  '{6}': { icon: '⑥', color: '#999' },
  '{7}': { icon: '⑦', color: '#999' },
  '{8}': { icon: '⑧', color: '#999' },
  '{9}': { icon: '⑨', color: '#999' },
  '{10}': { icon: '⑩', color: '#999' },
  '{X}': { icon: 'X', color: '#999' },
  '{W}': { icon: '◯', color: '#f8f8f0' }, // White
  '{U}': { icon: '◯', color: '#0074e4' }, // Blue
  '{B}': { icon: '◯', color: '#1a1a1a' }, // Black
  '{R}': { icon: '◯', color: '#e81828' }, // Red
  '{G}': { icon: '◯', color: '#0d673e' }, // Green
  '{C}': { icon: '◯', color: '#8b8b7a' }, // Colorless
  '{S}': { icon: '◯', color: '#999' }, // Snow
  '{P}': { icon: 'P', color: '#d3d3d3' }, // Phyrexian
}

export const useManaFormatter = () => {
  const formatMana = (manaCost: string): Array<{ text: string; color: string }> => {
    if (!manaCost) return []
    
    const manaRegex = /{[^}]+}/g
    const matches = manaCost.match(manaRegex) || []
    
    return matches.map(match => {
      const iconData = manaIcons[match]
      return {
        text: match.slice(1, -1), // Remove curly braces
        color: iconData?.color || '#999'
      }
    })
  }

  return { formatMana }
}
