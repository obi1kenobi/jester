States =

  # ### State flow: ###
  #
  # - new user account created:           INITIALIZING
  #                                            \/
  # - changed password to random:         STEADY_STATE  <---+
  #                                            \/           |
  # - requested token:                   CREATING_TOKEN     |
  #                                            \/           | (token
  # - token created successfully:          USING_TOKEN      |  successfully
  #                                            \/           |  revoked)
  # - token about to be revoked:         REVOKING_TOKEN ----+
  #
  # - when Jester couldn't find              INVALID
  #   a valid password to repair to
  #
  #
  # When profiles are loaded, all of them should be in STEADY_STATE or INVALID.
  # Any accounts that are not in one of these states require repair. One of the ways
  # this could happen is if the browser was closed while Jester was in the middle
  # of a password change operation. Repair proceeds as follows:
  # 1. Depending on the current state of the profile, possible password candidates
  #    are identified.
  # 2. Login is attempted with each password candidate.
  # 3. If no working password is discovered among the candidates, the profile
  #    is marked INVALID and the repair process is terminated.
  #    If a working password is discovered, the profile is marked INITIALIZING
  #    and the working password is set as the 'random password' of the profile.
  #    This ensures that any interruption during repair will not result in the
  #    working password being removed before being changed successfully.
  # 4. A new random password is generated and set on the account corresponding
  #    to the profile.
  # 5. The profile is set to STEADY_STATE.
  #

  # current password: user password
  # changing to:      random password
  INITIALIZING: 'initializing'

  # current password: random password
  # changing to:      none
  STEADY_STATE: 'steady-state'

  # current password: random password
  # changing to:      user password + token
  CREATING_TOKEN: 'creating-token'

  # current password: user password + token
  # changing to:      none
  USING_TOKEN: 'using-token'

  # current password: user password + token
  # changing to:      random password
  REVOKING_TOKEN: 'revoking-token'

  # none of the possible passwords are accepted as valid
  # could only occur as a result of user action
  # (e.g. the user manually changing their password on a service
  #  without updating the account info in Jester)
  INVALID: 'invalid'


module.exports = States
