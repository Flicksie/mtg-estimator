import { useSwal } from '../useSwal'

export const useExportArchidektErrorAlert = () => {
  const { fire: swal } = useSwal()

  const show = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error exporting to Archidekt: ${error}`,
      icon: 'error'
    })
  }

  return { show }
}
