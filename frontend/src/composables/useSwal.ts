import Swal, { SweetAlertOptions } from 'sweetalert2'

export const useSwal = () => {
  const defaultCustomClass = {
    container: 'swal-container',
    popup: 'swal-popup',
    title: 'swal-title',
    htmlContainer: 'swal-content',
    confirmButton: 'swal-btn-confirm',
    cancelButton: 'swal-btn-cancel',
    icon: 'swal-icon'
  }

  const fire = (options: SweetAlertOptions) => {
    // Close any existing alert before firing a new one
    Swal.close()
    
    return Swal.fire({
      borderRadius: '24px',
      width: '320px',
      allowOutsideClick: false,
      allowEscapeKey: false,
      customClass: defaultCustomClass,
      ...options
    })
  }

  return { fire }
}
