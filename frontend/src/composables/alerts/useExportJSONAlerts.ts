import { useSwal } from '../useSwal'

export const useExportJSONAlerts = () => {
  const { fire: swal } = useSwal()

  const showSuccess = async () => {
    return await swal({
      title: 'Exported!',
      text: 'Your collection has been exported as JSON',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  }

  const showError = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error exporting collection: ${error}`,
      icon: 'error'
    })
  }

  return { showSuccess, showError }
}
