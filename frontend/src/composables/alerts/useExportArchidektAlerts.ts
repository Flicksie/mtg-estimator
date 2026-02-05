import { useSwal } from '../useSwal'

export const useExportArchidektAlerts = () => {
  const { fire: swal } = useSwal()

  const showSuccess = async () => {
    return await swal({
      title: 'Exported to Archidekt!',
      html: 'Your collection has been exported as TXT.<br><br>You can import this file into Archidekt by:<br>1. Go to <a href="https://www.archidekt.com" target="_blank" rel="noopener noreferrer">archidekt.com</a><br>2. Create or edit a deck<br>3. Use the import/paste function to add the cards',
      icon: 'success',
      timer: 35000,
      timerProgressBar: true
    })
  }

  const showError = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error exporting to Archidekt: ${error}`,
      icon: 'error'
    })
  }

  return { showSuccess, showError }
}
