Aws.config[:wafregional] = {
  stub_responses: {
    list_web_acls: {
      next_marker: nil,
      web_acls: [
        {
          name: "WebACLexample", 
          web_acl_id: "webacl-1472061481310", 
        },
      ],
    },
    get_web_acl: {
      web_acl: {
        default_action: {
          type: "ALLOW", 
        }, 
        metric_name: "CreateExample", 
        name: "CreateExample", 
        rules: [
          {
            action: {
              type: "ALLOW", 
            }, 
            priority: 1, 
            rule_id: "example1ds3t-46da-4fdb-b8d5-abc321j569j5", 
          }, 
        ], 
        web_acl_id: "createwebacl-1472061481310", 
      }, 
    },
    get_rule: {
      rule: {
        metric_name: "WAFByteHeaderRule", 
        name: "WAFByteHeaderRule", 
        predicates: [
          {
            data_id: "1234567-abcd-1234-efgh-5678-1234567890", 
            negated: false,
            type: "IPMatch", 
          }, 
        ], 
        rule_id: "example1ds3t-46da-4fdb-b8d5-abc321j569j5", 
      }, 
    },
    list_ip_sets: {
      next_marker: nil,
      ip_sets: [
        {
          ip_set_id: '1234567-abcd-1234-efgh-5678-1234567890',
          name: 'regional-my-ip-set1'
        },
        {
          ip_set_id: '2234567-abcd-1234-efgh-5678-1234567890',
          name: 'regional-my-ip-set2'
        },
        {
          ip_set_id: '3234567-abcd-1234-efgh-5678-1234567890',
          name: 'regional-my-ip-set3'
        }
      ]
    }
  }
}
