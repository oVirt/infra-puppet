class ovirt_infra {
  package {['vim-enhanced', 'git']:
    ensure => installed,
  }

  ovirt_infra::user { 'eedri':
    key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAykXy+X1qUI/TyblF5J35A1bexPeFWj7SmzzcClS3GzQ8jEaV7AaOzbvyl2dQ8P4nh8tr2nSeT7LAFYWhIGscy6V7p5vMRr3mUzRA/E/g3r9wdmdDcPLOqfpJWiLTDlA3XQyFhJnwQopGRBSf5yzFGWFezH+rjzlwBDDN2mQkI/WuSEBh+UT/9+E7JvQBVhg2hapXszfSrrtrVniw/1TvNJEvR+wdwxCUkJWP+LZOtdbGIYQZMkmw8yMNy/fkEfxR3CLge65rDCbxqlDkqFff0VWcwd3SBXdIo4T1401kIjcPiPR9npib7Ra88QiWXIazHW05ejp+m2W136zmYmfxFw==',
  }

  ovirt_infra::user { 'ekohl':
    key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA0oQOkgks69qJkPIZeKC/uRGDyjkHHeULCdTtzs2I3ye0W0+Dg+Bl3rkhxX0S9xKanmhensvLfSXb01i6b5Qga9A8efVEgvQzDal456ahff64w+QPJ5IUPzfGYpGJAJp9MggjrgfOnIzfgC2Zo15rszOYuEmuLTsDs72kwvFVvZJJ9DPkaPvKCvoo3aykwbmJbVl7fDWPwvIKVOF+RwXeGqH2AsMwGyOVwn0Ik3ywcZhylkmoDg4RAS1n4F6gPk1GzHVcEYGMtwgVJQSi6FfEkkqwFfxRJUE562M0XwW5Zsy4FyiUsnHPMzIdcGQ1iSMGcV9z1506dSM0b/bN1guvgw==',
  }
}
