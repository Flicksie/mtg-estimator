import { useSwal } from '../useSwal'

export const useCardRemovalAlerts = () => {
  const { fire: swal } = useSwal()

  const showRemoved = async () => {
    return await swal({
      title: 'Removed!',
      text: 'Card removed from collection',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  }

  const showError = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error removing card: ${error}`,
      icon: 'error'
    })
  }

  return { showRemoved, showError }
}
