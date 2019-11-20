# The user for Krapali Rai
class ovirt_infra::user::krrai($password = undef) {
  ovirt_infra::user {'krrai':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC0zdycIMymOl+NrYt2Rqoat6eiMGVHv4NYCQqYgqy1ZGPzpcJk8w4n1D/ByntTEXXMUwZpyS/9G3lXe2U+TrHvlJZaqR6g2mJgzkciwKah3hcUwFQbZxvT/UrSAd0I/NTYHQX+bqabNNn8mXRS31NFkg6eCrx3euBrniegrWFOJNceBOB+HqO1IbquoOGA2gvAyVHluFCCHh3xFZTRBM7pO22gs3jDTERtGGjGpsWLQN22zhpLWh1ahVjL/Nsj1rnYIgzTQW7mvQ8dqAzJ73IT/PwY1B3PmRnvtoN9Uq6jJc3up02Efo8bKS18ouBXI29Hy1i6EbhIp6ln7LP3B487',
    password => $password,
  }
}

