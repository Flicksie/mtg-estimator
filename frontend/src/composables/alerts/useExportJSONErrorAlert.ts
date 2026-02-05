import { useSwal } from '../useSwal'

export const useExportJSONErrorAlert = () => {
  const { fire: swal } = useSwal()

  const show = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error exporting collection: ${error}`,
      icon: 'error'
    })
  }

  return { show }
}
