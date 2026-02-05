import { useSwal } from '../useSwal'

export const useClearCollectionConfirmAlert = () => {
  const { fire: swal } = useSwal()

  const show = async () => {
    return await swal({
      title: 'Clear Collection?',
      text: 'This will remove all cards from your collection. This cannot be undone!',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Clear All',
      cancelButtonText: 'Cancel'
    })
  }

  return { show }
}
