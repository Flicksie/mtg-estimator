import { useSwal } from '../useSwal'

export const useCardRemovedAlert = () => {
  const { fire: swal } = useSwal()

  const show = async () => {
    return await swal({
      title: 'Removed!',
      text: 'Card removed from collection',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  }

  return { show }
}
