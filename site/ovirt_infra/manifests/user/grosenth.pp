# The user for Galit
class ovirt_infra::user::grosenth($password = undef) {
  ovirt_infra::user {'grosenth':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQD1gN+yYgiUNlV0PdrX52g7pmQJsWOxP66dJZ2iZFR/nLEJ2j92yVl3poXpw4+lSIMWvuxTcILf+FY/NoDhB1GgG2617EaLPgFKKQdEb/wKNWZbAtkzK+st0UGqmFlY1jjvtsI+JEDOJORC8JFYUdArX8XfirpPK2Hqdbhws3RJk/IBuBNt1iBkFAtQXLZKa2O/VkvkvgOkHfnawDf1aMKw8uexh+C/SLDAMgKihi2TjtnRC8Tzyf1pFotoAvAVjrlHTmFJ51oGymsijDb4+Pv0cqQ4aeA4z5ic0ya95PC9t8ZoknGrchf8SEJXO+lPna6QjSrq+AEoeDW7sOFry0kIYvSfpMmC7IWOKwIMmolrfeePbPRLrL4EaMuh/ZoNDbOxxNnaYAJD3rbkQ4MWNuBoCCLAV0YftDX5xmFXRNF3vj3QFDGuNORySrsFIcwsI5cGMHEBfwnmluRzyWbL3YcHptohcTmUarNuHqugjVR0zlknJAKU6Tgu/BCo0ZaNpRVt6ofjElPwDhmSS+85Lck9Rh/QU9jh2P4HHKlXADClKRfYcNjVvUks1FIOtBvBjC8eBsWBOsMJV5wFUiklPyOvRVHK2PcboAEm9v3CgGnmZ7gQZK5343HgRRgfvDl5Ol+8yZX4F7JiI6UBR5XJI5Vh0dF8XJLsxhrye5+ejh93tw==',
    password => $password,
  }
}
