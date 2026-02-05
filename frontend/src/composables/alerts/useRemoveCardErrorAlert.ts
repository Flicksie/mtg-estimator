import { useSwal } from '../useSwal'

export const useRemoveCardErrorAlert = () => {
  const { fire: swal } = useSwal()

  const show = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error removing card: ${error}`,
      icon: 'error'
    })
  }

  return { show }
}
