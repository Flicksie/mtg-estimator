import { useSwal } from '../useSwal'

export const useExportMoxfieldAlerts = () => {
  const { fire: swal } = useSwal()

  const showSuccess = async () => {
    return await swal({
      title: 'Exported to Moxfield!',
      html: 'Your collection has been exported as CSV.<br><br>You can import this file into Moxfield by:<br>1. Go to <a href="https://www.moxfield.com" target="_blank" rel="noopener noreferrer">moxfield.com</a><br>2. Create or edit a deck<br>3. Use the import function to upload the CSV file',
      icon: 'success',
      timer: 35000,
      timerProgressBar: true
    })
  }

  const showError = async (error: string) => {
    return await swal({
      title: 'Error',
      text: `Error exporting to Moxfield: ${error}`,
      icon: 'error'
    })
  }

  return { showSuccess, showError }
}
