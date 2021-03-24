module ParametersType

use NamelistRead

implicit none
save
private

type, public :: parameters_type

  real, allocatable, dimension(:) :: bexp   ! b parameter
  real, allocatable, dimension(:) :: smcmax ! porosity (volumetric)
  real, allocatable, dimension(:) :: smcwlt ! wilting point
  real, allocatable, dimension(:) :: smcref ! field capacity
  real, allocatable, dimension(:) :: dksat  ! saturated conductivity
  real, allocatable, dimension(:) :: dwsat  ! saturated diffusivity
  real, allocatable, dimension(:) :: psisat ! saturated matric potential
  real                             :: bvic   ! VIC or DVIC model infiltration parameter
  real                            :: AXAJ   ! Xinanjiang: Tension water distribution inflection parameter [-]
  real                            :: BXAJ   ! Xinanjiang: Tension water distribution shape parameter [-]
  real                            :: XXAJ   ! Xinanjiang: Free water distribution shape parameter [-]
  real                            :: BBVIC  ! DVIC heterogeniety parameter for infiltration 
  real                            :: G      ! Mean Capillary Drive (m) for infiltration models
  real                            :: kdt    !
  real                            :: refkdt !
  real                            :: refdk  !
  real                            :: frzx   !
  real                            :: slope  ! drainage parameter
  real                            :: timean
  real                            :: fsatmx
  logical                         :: urban_flag
  real                            :: LAI
  real                            :: SAI
  real                            :: CH2OP !maximum intercepted h2o per unit lai+sai (mm)
  real                            :: ELAI
  real                            :: ESAI
  real                            :: FVEG ! vegetation fraction
  real                            :: GRAV     !acceleration due to gravity (m/s2)
  real                            :: SB       !Stefan-Boltzmann constant (w/m2/k4)
  real                            :: VKC      !von Karman constant
  real                            :: TFRZ     !freezing/melting point (k)
  real                            :: HSUB     !latent heat of sublimation (j/kg)
  real                            :: HVAP     !latent heat of vaporization (j/kg)
  real                            :: HFUS     !latent heat of fusion (j/kg)
  real                            :: CWAT     !specific heat capacity of water (j/m3/k)
  real                            :: CICE     !specific heat capacity of ice (j/m3/k)
  real                            :: CPAIR    !heat capacity dry air at const pres (j/kg/k)
  real                            :: TKWAT    !thermal conductivity of water (w/m/k)
  real                            :: TKICE    !thermal conductivity of ice (w/m/k)
  real                            :: TKAIR    !thermal conductivity of air (w/m/k) (not used MB: 20140718)
  real                            :: RAIR     !gas constant for dry air (j/kg/k)
  real                            :: RW       !gas constant for  water vapor (j/kg/k)
  real                            :: DENH2O   !density of water (kg/m3)
  real                            :: DENICE   !density of ice (kg/m3)
  real                            :: SSI      !liquid water holding capacity for snowpack (m3/m3)
  real                            :: WSLMAX   !maximum lake water storage (mm)
  real                            :: max_liq_mass_fraction !For snow water retention
  real                            :: SNOW_RET_FAC !snowpack water release timescale factor (1/s)
  integer                         :: NROOT    !vegetation root level

  contains

    procedure, public  :: Init         
    procedure, private :: InitAllocate 
    procedure, private :: InitDefault     
    procedure, public  :: InitTransfer

end type parameters_type

contains   

  subroutine Init(this, namelist)

    class(parameters_type) :: this
    type(namelist_type) :: namelist

    call this%InitAllocate(namelist)
    call this%InitDefault()

  end subroutine Init

  subroutine InitAllocate(this, namelist)

    class(parameters_type) :: this
    type(namelist_type) :: namelist

    allocate(this%bexp   (namelist%nsoil))  ; this%bexp   (:) = huge(1.0)
    allocate(this%smcmax (namelist%nsoil))  ; this%smcmax (:) = huge(1.0)
    allocate(this%smcwlt (namelist%nsoil))  ; this%smcwlt (:) = huge(1.0)
    allocate(this%smcref (namelist%nsoil))  ; this%smcref (:) = huge(1.0)
    allocate(this%dksat  (namelist%nsoil))  ; this%dksat  (:) = huge(1.0)
    allocate(this%dwsat  (namelist%nsoil))  ; this%dwsat  (:) = huge(1.0)
    allocate(this%psisat (namelist%nsoil))  ; this%psisat (:) = huge(1.0)

  end subroutine InitAllocate

  subroutine InitDefault(this)

    class(parameters_type) :: this

    this%ELAI       = huge(1.0)
    this%ESAI       = huge(1.0)
    this%FVEG       = huge(1.0)

  end subroutine InitDefault

  subroutine InitTransfer(this, namelist)

    class(parameters_type) :: this
    type(namelist_type) :: namelist

    this%bexp   = namelist%bb    (namelist%isltyp)
    this%smcmax = namelist%maxsmc(namelist%isltyp)
    this%smcwlt = namelist%wltsmc(namelist%isltyp)
    this%smcref = namelist%refsmc(namelist%isltyp)
    this%dksat  = namelist%satdk (namelist%isltyp)
    this%dwsat  = namelist%satdw (namelist%isltyp)
    this%psisat = namelist%satpsi(namelist%isltyp)
    this%bvic   = namelist%bvic  (namelist%isltyp)
    this%AXAJ   = namelist%AXAJ  (namelist%isltyp)
    this%BXAJ   = namelist%BXAJ  (namelist%isltyp)
    this%XXAJ   = namelist%XXAJ  (namelist%isltyp)
    this%BBVIC  = namelist%BBVIC (namelist%isltyp)
    this%G      = namelist%G     (namelist%isltyp)
    this%LAI    = namelist%LAI   (namelist%vegtyp)
    this%SAI    = namelist%SAI   (namelist%vegtyp)
    this%CH2OP  = namelist%CH2OP (namelist%vegtyp)
    this%NROOT  = namelist%NROOT (namelist%vegtyp)
    this%FVEG   = namelist%SHDMAX / 100.0
    IF(this%FVEG <= 0.05) this%FVEG = 0.05
    this%refkdt = namelist%refkdt
    this%refdk  = namelist%refdk
    this%kdt    = this%refkdt * this%dksat(1) / this%refdk
    this%frzx   = 0.15 * (this%smcmax(1) / this%smcref(1)) * (0.412 / 0.468)
    this%SSI    = namelist%SSI  
    this%slope      = namelist%slope
    this%urban_flag = .false.
    this%timean     = 10.5
    this%fsatmx     = 0.38 
    this%GRAV       = 9.80616
    this%SB         = 5.67E-08
    this%VKC        = 0.40 
    this%TFRZ       = 273.16 
    this%HSUB       = 2.8440E06
    this%HVAP       = 2.5104E06
    this%HFUS       = 0.3336E06
    this%CWAT       = 4.188E06
    this%CICE       = 2.094E06
    this%CPAIR      = 1004.64
    this%TKWAT      = 0.6
    this%TKICE      = 2.2
    this%TKAIR      = 0.023
    this%RAIR       = 287.04
    this%RW         = 461.269 
    this%DENH2O     = 1000.0
    this%DENICE     = 917.0
    this%WSLMAX     = 5000.0 
    this%max_liq_mass_fraction = 0.4
    this%SNOW_RET_FAC = 5.e-5

  end subroutine InitTransfer

end module ParametersType
