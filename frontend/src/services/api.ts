import type { Card, Stats, SearchResult, ScanResult, IdentifyResult, CollectionExport } from '../types'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000'

class ApiService {
  private async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const url = `${API_BASE_URL}${endpoint}`
    
    try {
      const response = await fetch(url, {
        ...options,
        headers: {
          ...options?.headers,
        },
        credentials: 'include', // Include cookies for session
      })

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}))
        throw new Error(errorData.error || `HTTP error! status: ${response.status}`)
      }

      return await response.json()
    } catch (error) {
      console.error('API request failed:', error)
      throw error
    }
  }

  // Stats
  async getStats(): Promise<Stats> {
    return this.request<Stats>('/api/stats')
  }

  // Card Search
  async searchCard(query: string): Promise<SearchResult> {
    return this.request<SearchResult>('/api/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query }),
    })
  }

  // Scanner
  async scanImage(file: File, geminiKey?: string): Promise<ScanResult> {
    const formData = new FormData()
    formData.append('image', file)
    if (geminiKey) {
      formData.append('gemini_key', geminiKey)
    }

    return this.request<ScanResult>('/api/scan', {
      method: 'POST',
      body: formData,
    })
  }

  async identifyCards(cardNames: string[]): Promise<IdentifyResult> {
    return this.request<IdentifyResult>('/api/identify', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ card_names: cardNames }),
    })
  }

  // Collection
  async getCollection(): Promise<Card[]> {
    return this.request<Card[]>('/api/collection/list')
  }

  async addToCollection(card: Partial<Card>): Promise<{ success: boolean; card: Card }> {
    return this.request('/api/collection/add', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(card),
    })
  }

  async removeFromCollection(cardId: number): Promise<{ success: boolean }> {
    return this.request(`/api/collection/remove/${cardId}`, {
      method: 'DELETE',
    })
  }

  async exportCollection(): Promise<CollectionExport> {
    return this.request<CollectionExport>('/api/collection/export')
  }

  async clearCollection(): Promise<{ success: boolean }> {
    return this.request('/api/collection/clear', {
      method: 'POST',
    })
  }
}

export default new ApiService()
