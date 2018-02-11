# assign this pillar together with mn.photosync to a node to create a sftp service
# that can be used to share photos from iOS devices. The structure is
#
# photosync -> groupname -> username -> sha-512 passwd
#
photosync:
    example:
        testuser: $6$Kc/L3dkzgF0$W/2JRHJ.ZlVUl/Dh5TirdkLN2XzswY/ZCbQRLsgITWf07O6GHxfZr4LG2rvHmm4ACgyfIV1UgeHhe1d2kXGki/
