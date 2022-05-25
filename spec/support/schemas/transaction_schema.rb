# frozen_string_literal: true

module TransactionSchema
  extend self

  def call
    {
      'type' => 'object',
      'required' => %w[data included],
      'additionalProperties' => false,
      'properties' => {
        'data' => {
          'type' => 'object',
          'required' => %w[
            id type attributes
          ],
          'properties' => {
            'id' => {
              'type' => 'string'
            },
            'type' => {
              'type' => 'string',
              'enum' => ['transaction']
            },
            'attributes' => {
              'type' => 'object',
              'required' => %w[
                amount description
              ],
              'properties' => {
                'amount' => {
                  'type' => 'string'
                },
                'description' => {
                  'type' => 'string'
                }
              }
            },
            'relationships' => {
              'type' => 'object',
              'required' => %w[
                sender receiver
              ],
              'properties' => {
                'sender' => {
                  'type' => 'object',
                  'required' => %w[data],
                  'properties' => {
                    'data' => {
                      'type' => 'object',
                      'required' => %w[id type],
                      'properties' => {
                        'id' => {
                          'type' => 'string'
                        },
                        'type' => {
                          'type' => 'string',
                          'enum' => ['account']
                        }
                      }

                    }
                  }
                },
                'receiver' => {
                  'type' => 'object',
                  'required' => %w[data],
                  'properties' => {
                    'data' => {
                      'type' => 'object',
                      'required' => %w[id type],
                      'properties' => {
                        'id' => {
                          'type' => 'string'
                        },
                        'type' => {
                          'type' => 'string',
                          'enum' => ['account']
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        'included' => {
          'type' => 'array',
          'items' => {
            'oneOf' => [
              {
                'type' => 'object',
                'required' => %w[id type attributes],
                'properties' => {
                  'id' => {
                    'type' => 'string'
                  },
                  'type' => {
                    'type' => 'string',
                    'enum' => %w[user]
                  },
                  'attributes' => {
                    'type' => 'object',
                    'required' => %w[first_name last_name],
                    'properties' => {
                      'first_name' => {
                        'type' => 'string'
                      },
                      'last_name' => {
                        'type' => 'string'
                      }
                    }
                  }
                }
              },
              {
                'type' => 'object',
                'required' => %w[id type relationships],
                'properties' => {
                  'id' => {
                    'type' => 'string'
                  },
                  'type' => {
                    'type' => 'string',
                    'enum' => %w[account]
                  },
                  'relationships' => {
                    'type' => 'object',
                    'required' => %w[user],
                    'properties' => {
                      'user' => {
                        'type' => 'object',
                        'required' => %w[data],
                        'properties' => {
                          'data' => {
                            'type' => 'object',
                            'required' => %w[id type],
                            'properties' => {
                              'id' => {
                                'type' => 'string'
                              },
                              'type' => {
                                'type' => 'string',
                                'enum' => %w[user]
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            ]
          }
        }
      }
    }.freeze
  end
end
