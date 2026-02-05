import { useSwal } from '../useSwal'

export const useExportJSONAlert = () => {
  const { fire: swal } = useSwal()

  const show = async () => {
    return await swal({
      title: 'Exported!',
      text: 'Your collection has been exported as JSON',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  }

  return { show }
}
