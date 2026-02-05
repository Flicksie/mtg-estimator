import Swal, { SweetAlertOptions } from 'sweetalert2'

export const useSwal = () => {
  // Base configuration for all alerts
  const baseConfig: SweetAlertOptions = {
    borderRadius: '24px',
    width: '320px',
    customClass: {
      container: 'swal-container',
      popup: 'swal-popup',
      title: 'swal-title',
      htmlContainer: 'swal-content',
      confirmButton: 'swal-btn-confirm',
      cancelButton: 'swal-btn-cancel',
      icon: 'swal-icon'
    }
  }

  const fire = (options: SweetAlertOptions) => {
    return Swal.fire({
      ...baseConfig,
      ...options
    })
  }

  return { fire }
}
