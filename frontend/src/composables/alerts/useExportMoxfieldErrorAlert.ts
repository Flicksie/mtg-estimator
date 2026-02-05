import { useSwal } from '../useSwal'

export const useExportMoxfieldErrorAlert = () => {
  const { fire: swal } = useSwal()

  const show = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error exporting to Moxfield: ${error}`,
      icon: 'error'
    })
  }

  return { show }
}
