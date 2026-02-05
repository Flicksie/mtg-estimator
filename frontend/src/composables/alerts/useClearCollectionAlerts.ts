import { useSwal } from '../useSwal'

export const useClearCollectionAlerts = () => {
  const { fire: swal } = useSwal()

  const showConfirm = async () => {
    return await swal({
      title: 'Clear Collection?',
      text: 'This will remove all cards from your collection. This cannot be undone!',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Clear All',
      cancelButtonText: 'Cancel'
    })
  }

  const showCleared = async () => {
    return await swal({
      title: 'Cleared!',
      text: 'Your collection has been cleared',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  }

  const showError = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error clearing collection: ${error}`,
      icon: 'error'
    })
  }

  return { showConfirm, showCleared, showError }
}
