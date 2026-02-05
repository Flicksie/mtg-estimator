import { useSwal } from '../useSwal'

export const useClearedAlert = () => {
  const { fire: swal } = useSwal()

  const show = async () => {
    return await swal({
      title: 'Cleared!',
      text: 'Your collection has been cleared',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  }

  return { show }
}
