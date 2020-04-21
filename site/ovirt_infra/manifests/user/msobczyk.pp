# The user for Marcin Sobczyk
class ovirt_infra::user::msobczyk($password = undef) {
  ovirt_infra::user { 'msobczyk':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABgQC9cjyDtAYdsSxOnni0iFGVPBJ8ol2l1ZUN+YoyXsBP16ZqBjOIihY9BwExO7VVPsZSLh2vbTGek2acCGfdV5aUi5aZEPAAgTaXVop8D03D+bJLsOWoCmECwYhVuSnbm3r5ce83TuhjyvRgivpx8JPgRFbquuag89RChIUoPmJji65T3hINDV71UDcfikLWTiNsT+dhAccFsmBPKjec1zhEEiXJs6NO5ZqUTYpXA3UaC2UQWI6mtNIlyz9WLxtw09uZxcHV+OVoQH5q+VEDrdqnp09utyr6Rcr80HsJwqjNcC3l0LBDu8Ud9d7r1PIEhIwwlnd8syYYCaT+AD2t9YTr4j3sHhtgRG7SGpiM2Oi1rSr/MgeUAIcxLO7XaUa1cUNbiHFuMt5H7+rEE1Na6UUj1d1EsiT27O3FmBGdvlU0k78kyLIIV8LM3XXpAEQ+5BF96j0i1WSr8DB9BbcinIt1Vh8LeBM/WnMNn2M/hkwSepfQZCG39IWTLpmwcAnSPaM=',
    password => $password,
  }
}
