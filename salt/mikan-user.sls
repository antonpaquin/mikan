mikan_user:
    user.present:
        - name: mikan
        - password: $1$SExb/HGZ$AplNLVGCVAc1Am1vMvqkF1  # mikan
        - home: /home/mikan
        - shell: /bin/bash
        - createhome: True

wheel:
    group.present:
        - members: 
            - mikan
        - require:
            - user: mikan_user

/etc/sudoers:
    file.append:
        - text: '%wheel ALL=(ALL) NOPASSWD:ALL'
