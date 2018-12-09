Aws.config[:wafregional] = {
  stub_responses: {
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
