import { useSwal } from '../useSwal'

export const useClearCollectionErrorAlert = () => {
  const { fire: swal } = useSwal()

  const show = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error clearing collection: ${error}`,
      icon: 'error'
    })
  }

  return { show }
}
