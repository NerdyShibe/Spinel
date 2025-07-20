# rubocop:disable Metrics/ModuleLength
# frozen_string_literal: true

module Spinel
  module Cpu
    module Opcodes
      #------------------------------------------------------------------#
      # Main Opcodes (0x00 - 0xFF)
      #------------------------------------------------------------------#

      # 0x00 - 0x0F
      NOP             = 0x00
      LD_BC_IMM16     = 0x01
      LD_MEM_BC_A     = 0x02
      INC_BC          = 0x03
      INC_B           = 0x04
      DEC_B           = 0x05
      LD_B_IMM8       = 0x06
      RLCA            = 0x07
      LD_MEM_IMM16_SP = 0x08
      ADD_HL_BC       = 0x09
      LD_A_MEM_BC     = 0x0A
      DEC_BC          = 0x0B
      INC_C           = 0x0C
      DEC_C           = 0x0D
      LD_C_IMM8       = 0x0E
      RRCA            = 0x0F

      # 0x10 - 0x1F
      STOP          = 0x10
      LD_DE_IMM16   = 0x11
      LD_MEM_DE_A   = 0x12
      INC_DE        = 0x13
      INC_D         = 0x14
      DEC_D         = 0x15
      LD_D_IMM8     = 0x16
      RLA           = 0x17
      JR_IMM8       = 0x18
      ADD_HL_DE     = 0x19
      LD_A_MEM_DE   = 0x1A
      DEC_DE        = 0x1B
      INC_E         = 0x1C
      DEC_E         = 0x1D
      LD_E_IMM8     = 0x1E
      RRA           = 0x1F

      # 0x20 - 0x2F
      JR_NZ_IMM8    = 0x20
      LD_HL_IMM16   = 0x21
      LD_MEM_HL_INC_A = 0x22 # LD (HL+), A
      INC_HL        = 0x23
      INC_H         = 0x24
      DEC_H         = 0x25
      LD_H_IMM8     = 0x26
      DAA           = 0x27
      JR_Z_IMM8     = 0x28
      ADD_HL_HL     = 0x29
      LD_A_MEM_HL_INC = 0x2A # LD A, (HL+)
      DEC_HL        = 0x2B
      INC_L         = 0x2C
      DEC_L         = 0x2D
      LD_L_IMM8     = 0x2E
      CPL           = 0x2F

      # 0x30 - 0x3F
      JR_NC_IMM8    = 0x30
      LD_SP_IMM16   = 0x31
      LD_MEM_HL_DEC_A = 0x32 # LD (HL-), A
      INC_SP        = 0x33
      INC_MEM_HL    = 0x34
      DEC_MEM_HL    = 0x35
      LD_MEM_HL_IMM8 = 0x36
      SCF           = 0x37
      JR_C_IMM8     = 0x38
      ADD_HL_SP     = 0x39
      LD_A_MEM_HL_DEC = 0x3A # LD A, (HL-)
      DEC_SP        = 0x3B
      INC_A         = 0x3C
      DEC_A         = 0x3D
      LD_A_IMM8     = 0x3E
      CCF           = 0x3F

      # 0x40 - 0x4F
      LD_B_B        = 0x40
      LD_B_C        = 0x41
      LD_B_D        = 0x42
      LD_B_E        = 0x43
      LD_B_H        = 0x44
      LD_B_L        = 0x45
      LD_B_MEM_HL   = 0x46
      LD_B_A        = 0x47
      LD_C_B        = 0x48
      LD_C_C        = 0x49
      LD_C_D        = 0x4A
      LD_C_E        = 0x4B
      LD_C_H        = 0x4C
      LD_C_L        = 0x4D
      LD_C_MEM_HL   = 0x4E
      LD_C_A        = 0x4F

      # 0x50 - 0x5F
      LD_D_B        = 0x50
      LD_D_C        = 0x51
      LD_D_D        = 0x52
      LD_D_E        = 0x53
      LD_D_H        = 0x54
      LD_D_L        = 0x55
      LD_D_MEM_HL   = 0x56
      LD_D_A        = 0x57
      LD_E_B        = 0x58
      LD_E_C        = 0x59
      LD_E_D        = 0x5A
      LD_E_E        = 0x5B
      LD_E_H        = 0x5C
      LD_E_L        = 0x5D
      LD_E_MEM_HL   = 0x5E
      LD_E_A        = 0x5F

      # 0x60 - 0x6F
      LD_H_B        = 0x60
      LD_H_C        = 0x61
      LD_H_D        = 0x62
      LD_H_E        = 0x63
      LD_H_H        = 0x64
      LD_H_L        = 0x65
      LD_H_MEM_HL   = 0x66
      LD_H_A        = 0x67
      LD_L_B        = 0x68
      LD_L_C        = 0x69
      LD_L_D        = 0x6A
      LD_L_E        = 0x6B
      LD_L_H        = 0x6C
      LD_L_L        = 0x6D
      LD_L_MEM_HL   = 0x6E
      LD_L_A        = 0x6F

      # 0x70 - 0x7F
      LD_MEM_HL_B   = 0x70
      LD_MEM_HL_C   = 0x71
      LD_MEM_HL_D   = 0x72
      LD_MEM_HL_E   = 0x73
      LD_MEM_HL_H   = 0x74
      LD_MEM_HL_L   = 0x75
      HALT          = 0x76
      LD_MEM_HL_A   = 0x77
      LD_A_B        = 0x78
      LD_A_C        = 0x79
      LD_A_D        = 0x7A
      LD_A_E        = 0x7B
      LD_A_H        = 0x7C
      LD_A_L        = 0x7D
      LD_A_MEM_HL   = 0x7E
      LD_A_A        = 0x7F

      # 0x80 - 0x8F
      ADD_A_B       = 0x80
      ADD_A_C       = 0x81
      ADD_A_D       = 0x82
      ADD_A_E       = 0x83
      ADD_A_H       = 0x84
      ADD_A_L       = 0x85
      ADD_A_MEM_HL  = 0x86
      ADD_A_A       = 0x87
      ADC_A_B       = 0x88
      ADC_A_C       = 0x89
      ADC_A_D       = 0x8A
      ADC_A_E       = 0x8B
      ADC_A_H       = 0x8C
      ADC_A_L       = 0x8D
      ADC_A_MEM_HL  = 0x8E
      ADC_A_A       = 0x8F

      # 0x90 - 0x9F
      SUB_A_B       = 0x90
      SUB_A_C       = 0x91
      SUB_A_D       = 0x92
      SUB_A_E       = 0x93
      SUB_A_H       = 0x94
      SUB_A_L       = 0x95
      SUB_A_MEM_HL  = 0x96
      SUB_A_A       = 0x97
      SBC_A_B       = 0x98
      SBC_A_C       = 0x99
      SBC_A_D       = 0x9A
      SBC_A_E       = 0x9B
      SBC_A_H       = 0x9C
      SBC_A_L       = 0x9D
      SBC_A_MEM_HL  = 0x9E
      SBC_A_A       = 0x9F

      # 0xA0 - 0xAF
      AND_A_B       = 0xA0
      AND_A_C       = 0xA1
      AND_A_D       = 0xA2
      AND_A_E       = 0xA3
      AND_A_H       = 0xA4
      AND_A_L       = 0xA5
      AND_A_MEM_HL  = 0xA6
      AND_A_A       = 0xA7
      XOR_A_B       = 0xA8
      XOR_A_C       = 0xA9
      XOR_A_D       = 0xAA
      XOR_A_E       = 0xAB
      XOR_A_H       = 0xAC
      XOR_A_L       = 0xAD
      XOR_A_MEM_HL  = 0xAE
      XOR_A_A       = 0xAF

      # 0xB0 - 0xBF
      OR_A_B        = 0xB0
      OR_A_C        = 0xB1
      OR_A_D        = 0xB2
      OR_A_E        = 0xB3
      OR_A_H        = 0xB4
      OR_A_L        = 0xB5
      OR_A_MEM_HL   = 0xB6
      OR_A_A        = 0xB7
      CP_A_B        = 0xB8
      CP_A_C        = 0xB9
      CP_A_D        = 0xBA
      CP_A_E        = 0xBB
      CP_A_H        = 0xBC
      CP_A_L        = 0xBD
      CP_A_MEM_HL   = 0xBE
      CP_A_A        = 0xBF

      # 0xC0 - 0xCF
      RET_NZ        = 0xC0
      POP_BC        = 0xC1
      JP_NZ_IMM16   = 0xC2
      JP_IMM16      = 0xC3
      CALL_NZ_IMM16 = 0xC4
      PUSH_BC       = 0xC5
      ADD_A_IMM8    = 0xC6
      RST_00H       = 0xC7
      RET_Z         = 0xC8
      RET           = 0xC9
      JP_Z_IMM16    = 0xCA
      PREFIX_CB     = 0xCB # CB Prefix
      CALL_Z_IMM16  = 0xCC
      CALL_IMM16    = 0xCD
      ADC_A_IMM8    = 0xCE
      RST_08H       = 0xCF

      # 0xD0 - 0xDF
      RET_NC        = 0xD0
      POP_DE        = 0xD1
      JP_NC_IMM16   = 0xD2
      # 0xD3 - Unused
      CALL_NC_IMM16 = 0xD4
      PUSH_DE       = 0xD5
      SUB_A_IMM8    = 0xD6
      RST_10H       = 0xD7
      RET_C         = 0xD8
      RETI          = 0xD9
      JP_C_IMM16    = 0xDA
      # 0xDB - Unused
      CALL_C_IMM16  = 0xDC
      # 0xDD - Unused
      SBC_A_IMM8    = 0xDE
      RST_18H       = 0xDF

      # 0xE0 - 0xEF
      LD_MEM_IMM8_OFFSET_A = 0xE0 # LDH (a8), A
      POP_HL               = 0xE1
      LD_MEM_C_OFFSET_A    = 0xE2 # LD (C), A
      # 0xE3 - Unused
      # 0xE4 - Unused
      PUSH_HL        = 0xE5
      AND_A_IMM8     = 0xE6
      RST_20H        = 0xE7
      ADD_SP_IMM8    = 0xE8
      JP_HL          = 0xE9
      LD_MEM_IMM16_A = 0xEA
      # 0xEB - Unused
      # 0xEC - Unused
      # 0xED - Unused
      XOR_A_IMM8    = 0xEE
      RST_28H       = 0xEF

      # 0xF0 - 0xFF
      LD_A_MEM_IMM8_OFFSET = 0xF0 # LDH A, (a8)
      POP_AF = 0xF1
      LD_A_MEM_C_OFFSET = 0xF2 # LD A, (C)
      DI            = 0xF3
      # 0xF4 - Unused
      PUSH_AF       = 0xF5
      OR_A_IMM8     = 0xF6
      RST_30H       = 0xF7
      LD_HL_SP_IMM8 = 0xF8
      LD_SP_HL      = 0xF9
      LD_A_MEM_IMM16 = 0xFA
      EI            = 0xFB
      # 0xFC - Unused
      # 0xFD - Unused
      CP_A_IMM8     = 0xFE
      RST_38H       = 0xFF

      #------------------------------------------------------------------#
      # ## CB-Prefixed Opcodes
      # These opcodes follow the 0xCB prefix byte.
      # For example, the instruction RLC B is encoded as 0xCB 0x00.
      #------------------------------------------------------------------#

      # 0x00 - 0x0F
      RLC_B       = 0x00
      RLC_C       = 0x01
      RLC_D       = 0x02
      RLC_E       = 0x03
      RLC_H       = 0x04
      RLC_L       = 0x05
      RLC_MEM_HL  = 0x06
      RLC_A       = 0x07
      RRC_B       = 0x08
      RRC_C       = 0x09
      RRC_D       = 0x0A
      RRC_E       = 0x0B
      RRC_H       = 0x0C
      RRC_L       = 0x0D
      RRC_MEM_HL  = 0x0E
      RRC_A       = 0x0F

      # 0x10 - 0x1F
      RL_B        = 0x10
      RL_C        = 0x11
      RL_D        = 0x12
      RL_E        = 0x13
      RL_H        = 0x14
      RL_L        = 0x15
      RL_MEM_HL   = 0x16
      RL_A        = 0x17
      RR_B        = 0x18
      RR_C        = 0x19
      RR_D        = 0x1A
      RR_E        = 0x1B
      RR_H        = 0x1C
      RR_L        = 0x1D
      RR_MEM_HL   = 0x1E
      RR_A        = 0x1F

      # 0x20 - 0x2F
      SLA_B       = 0x20
      SLA_C       = 0x21
      SLA_D       = 0x22
      SLA_E       = 0x23
      SLA_H       = 0x24
      SLA_L       = 0x25
      SLA_MEM_HL  = 0x26
      SLA_A       = 0x27
      SRA_B       = 0x28
      SRA_C       = 0x29
      SRA_D       = 0x2A
      SRA_E       = 0x2B
      SRA_H       = 0x2C
      SRA_L       = 0x2D
      SRA_MEM_HL  = 0x2E
      SRA_A       = 0x2F

      # 0x30 - 0x3F
      SWAP_B      = 0x30
      SWAP_C      = 0x31
      SWAP_D      = 0x32
      SWAP_E      = 0x33
      SWAP_H      = 0x34
      SWAP_L      = 0x35
      SWAP_MEM_HL = 0x36
      SWAP_A      = 0x37
      SRL_B       = 0x38
      SRL_C       = 0x39
      SRL_D       = 0x3A
      SRL_E       = 0x3B
      SRL_H       = 0x3C
      SRL_L       = 0x3D
      SRL_MEM_HL  = 0x3E
      SRL_A       = 0x3F

      # 0x40 - 0x7F (BIT b, r)
      # BIT 0
      BIT_0_B     = 0x40
      BIT_0_C     = 0x41
      BIT_0_D     = 0x42
      BIT_0_E     = 0x43
      BIT_0_H     = 0x44
      BIT_0_L     = 0x45
      BIT_0_MEM_HL = 0x46
      BIT_0_A     = 0x47
      # BIT 1
      BIT_1_B     = 0x48
      BIT_1_C     = 0x49
      BIT_1_D     = 0x4A
      BIT_1_E     = 0x4B
      BIT_1_H     = 0x4C
      BIT_1_L     = 0x4D
      BIT_1_MEM_HL = 0x4E
      BIT_1_A     = 0x4F
      # BIT 2
      BIT_2_B     = 0x50
      BIT_2_C     = 0x51
      BIT_2_D     = 0x52
      BIT_2_E     = 0x53
      BIT_2_H     = 0x54
      BIT_2_L     = 0x55
      BIT_2_MEM_HL = 0x56
      BIT_2_A     = 0x57
      # BIT 3
      BIT_3_B     = 0x58
      BIT_3_C     = 0x59
      BIT_3_D     = 0x5A
      BIT_3_E     = 0x5B
      BIT_3_H     = 0x5C
      BIT_3_L     = 0x5D
      BIT_3_MEM_HL = 0x5E
      BIT_3_A     = 0x5F
      # BIT 4
      BIT_4_B     = 0x60
      BIT_4_C     = 0x61
      BIT_4_D     = 0x62
      BIT_4_E     = 0x63
      BIT_4_H     = 0x64
      BIT_4_L     = 0x65
      BIT_4_MEM_HL = 0x66
      BIT_4_A     = 0x67
      # BIT 5
      BIT_5_B     = 0x68
      BIT_5_C     = 0x69
      BIT_5_D     = 0x6A
      BIT_5_E     = 0x6B
      BIT_5_H     = 0x6C
      BIT_5_L     = 0x6D
      BIT_5_MEM_HL = 0x6E
      BIT_5_A     = 0x6F
      # BIT 6
      BIT_6_B     = 0x70
      BIT_6_C     = 0x71
      BIT_6_D     = 0x72
      BIT_6_E     = 0x73
      BIT_6_H     = 0x74
      BIT_6_L     = 0x75
      BIT_6_MEM_HL = 0x76
      BIT_6_A     = 0x77
      # BIT 7
      BIT_7_B     = 0x78
      BIT_7_C     = 0x79
      BIT_7_D     = 0x7A
      BIT_7_E     = 0x7B
      BIT_7_H     = 0x7C
      BIT_7_L     = 0x7D
      BIT_7_MEM_HL = 0x7E
      BIT_7_A     = 0x7F

      # 0x80 - 0xBF (RES b, r)
      # RES 0
      RES_0_B     = 0x80
      RES_0_C     = 0x81
      RES_0_D     = 0x82
      RES_0_E     = 0x83
      RES_0_H     = 0x84
      RES_0_L     = 0x85
      RES_0_MEM_HL = 0x86
      RES_0_A     = 0x87
      # RES 1
      RES_1_B     = 0x88
      RES_1_C     = 0x89
      RES_1_D     = 0x8A
      RES_1_E     = 0x8B
      RES_1_H     = 0x8C
      RES_1_L     = 0x8D
      RES_1_MEM_HL = 0x8E
      RES_1_A     = 0x8F
      # RES 2
      RES_2_B     = 0x90
      RES_2_C     = 0x91
      RES_2_D     = 0x92
      RES_2_E     = 0x93
      RES_2_H     = 0x94
      RES_2_L     = 0x95
      RES_2_MEM_HL = 0x96
      RES_2_A     = 0x97
      # RES 3
      RES_3_B     = 0x98
      RES_3_C     = 0x99
      RES_3_D     = 0x9A
      RES_3_E     = 0x9B
      RES_3_H     = 0x9C
      RES_3_L     = 0x9D
      RES_3_MEM_HL = 0x9E
      RES_3_A     = 0x9F
      # RES 4
      RES_4_B     = 0xA0
      RES_4_C     = 0xA1
      RES_4_D     = 0xA2
      RES_4_E     = 0xA3
      RES_4_H     = 0xA4
      RES_4_L     = 0xA5
      RES_4_MEM_HL = 0xA6
      RES_4_A     = 0xA7
      # RES 5
      RES_5_B     = 0xA8
      RES_5_C     = 0xA9
      RES_5_D     = 0xAA
      RES_5_E     = 0xAB
      RES_5_H     = 0xAC
      RES_5_L     = 0xAD
      RES_5_MEM_HL = 0xAE
      RES_5_A     = 0xAF
      # RES 6
      RES_6_B     = 0xB0
      RES_6_C     = 0xB1
      RES_6_D     = 0xB2
      RES_6_E     = 0xB3
      RES_6_H     = 0xB4
      RES_6_L     = 0xB5
      RES_6_MEM_HL = 0xB6
      RES_6_A     = 0xB7
      # RES 7
      RES_7_B     = 0xB8
      RES_7_C     = 0xB9
      RES_7_D     = 0xBA
      RES_7_E     = 0xBB
      RES_7_H     = 0xBC
      RES_7_L     = 0xBD
      RES_7_MEM_HL = 0xBE
      RES_7_A = 0xBF

      # 0xC0 - 0xFF (SET b, r)
      # SET 0
      SET_0_B      = 0xC0
      SET_0_C      = 0xC1
      SET_0_D      = 0xC2
      SET_0_E      = 0xC3
      SET_0_H      = 0xC4
      SET_0_L      = 0xC5
      SET_0_MEM_HL = 0xC6
      SET_0_A      = 0xC7
      # SET 1
      SET_1_B      = 0xC8
      SET_1_C      = 0xC9
      SET_1_D      = 0xCA
      SET_1_E      = 0xCB
      SET_1_H      = 0xCC
      SET_1_L      = 0xCD
      SET_1_MEM_HL = 0xCE
      SET_1_A      = 0xCF
      # SET 2
      SET_2_B      = 0xD0
      SET_2_C      = 0xD1
      SET_2_D      = 0xD2
      SET_2_E      = 0xD3
      SET_2_H      = 0xD4
      SET_2_L      = 0xD5
      SET_2_MEM_HL = 0xD6
      SET_2_A      = 0xD7
      # SET 3
      SET_3_B      = 0xD8
      SET_3_C      = 0xD9
      SET_3_D      = 0xDA
      SET_3_E      = 0xDB
      SET_3_H      = 0xDC
      SET_3_L      = 0xDD
      SET_3_MEM_HL = 0xDE
      SET_3_A      = 0xDF
      # SET 4
      SET_4_B      = 0xE0
      SET_4_C      = 0xE1
      SET_4_D      = 0xE2
      SET_4_E      = 0xE3
      SET_4_H      = 0xE4
      SET_4_L      = 0xE5
      SET_4_MEM_HL = 0xE6
      SET_4_A      = 0xE7
      # SET 5
      SET_5_B      = 0xE8
      SET_5_C      = 0xE9
      SET_5_D      = 0xEA
      SET_5_E      = 0xEB
      SET_5_H      = 0xEC
      SET_5_L      = 0xED
      SET_5_MEM_HL = 0xEE
      SET_5_A      = 0xEF
      # SET 6
      SET_6_B      = 0xF0
      SET_6_C      = 0xF1
      SET_6_D      = 0xF2
      SET_6_E      = 0xF3
      SET_6_H      = 0xF4
      SET_6_L      = 0xF5
      SET_6_MEM_HL = 0xF6
      SET_6_A      = 0xF7
      # SET 7
      SET_7_B      = 0xF8
      SET_7_C      = 0xF9
      SET_7_D      = 0xFA
      SET_7_E      = 0xFB
      SET_7_H      = 0xFC
      SET_7_L      = 0xFD
      SET_7_MEM_HL = 0xFE
      SET_7_A      = 0xFF

      # OPCODES = [
      #   { opcode: 0x00, mnemonic: 'NOP', length: 1, cycles: 4, method: :nop, operands: [] },
      #   { opcode: 0x01, mnemonic: 'LD BC, d16', length: 3, cycles: 12, method: :load_r16_imm16, operands: [:bc=] },
      #   { opcode: 0x02, mnemonic: 'LD (BC), A', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[bc a] },
      #   { opcode: 0x03, mnemonic: 'INC BC', length: 1, cycles: 8, method: :inc_r16, operands: [:bc] },
      #   { opcode: 0x04, mnemonic: 'INC B', length: 1, cycles: 4, method: :inc_r8, operands: [:b] },
      #   { opcode: 0x05, mnemonic: 'DEC B', length: 1, cycles: 4, method: :dec_r8, operands: [:b] },
      #   { opcode: 0x06, mnemonic: 'LD B, d8', length: 2, cycles: 8, method: :load_r8_d8, operands: [:b] },
      #   { opcode: 0x07, mnemonic: 'RLCA', length: 1, cycles: 4, method: :rlca, operands: [] },
      #   { opcode: 0x08, mnemonic: 'LD (a16), SP', length: 3, cycles: 20, method: :load_mem_sp, operands: %i[a16 sp] },
      #   { opcode: 0x09, mnemonic: 'ADD HL, BC', length: 1, cycles: 8, method: :add_hl_r16, operands: [:bc] },
      #   { opcode: 0x0A, mnemonic: 'LD A, (BC)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[a bc] },
      #   { opcode: 0x0B, mnemonic: 'DEC BC', length: 1, cycles: 8, method: :dec_r16, operands: [:bc] },
      #   { opcode: 0x0C, mnemonic: 'INC C', length: 1, cycles: 4, method: :inc_r8, operands: [:c] },
      #   { opcode: 0x0D, mnemonic: 'DEC C', length: 1, cycles: 4, method: :dec_r8, operands: [:c] },
      #   { opcode: 0x0E, mnemonic: 'LD C, d8', length: 2, cycles: 8, method: :load_r8_d8, operands: [:c] },
      #   { opcode: 0x0F, mnemonic: 'RRCA', length: 1, cycles: 4, method: :rrca, operands: [] },
      #   { opcode: 0x10, mnemonic: 'STOP', length: 2, cycles: 4, method: :stop, operands: [] },
      #   { opcode: 0x11, mnemonic: 'LD DE, d16', length: 3, cycles: 12, method: :load_r16_imm16, operands: [:de=] },
      #   { opcode: 0x12, mnemonic: 'LD (DE), A', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[de a] },
      #   { opcode: 0x13, mnemonic: 'INC DE', length: 1, cycles: 8, method: :inc_r16, operands: [:de] },
      #   { opcode: 0x14, mnemonic: 'INC D', length: 1, cycles: 4, method: :inc_r8, operands: [:d] },
      #   { opcode: 0x15, mnemonic: 'DEC D', length: 1, cycles: 4, method: :dec_r8, operands: [:d] },
      #   { opcode: 0x16, mnemonic: 'LD D, d8', length: 2, cycles: 8, method: :load_r8_d8, operands: [:d] },
      #   { opcode: 0x17, mnemonic: 'RLA', length: 1, cycles: 4, method: :rla, operands: [] },
      #   { opcode: 0x18, mnemonic: 'JR r8', length: 2, cycles: 12, method: :jump_relative, operands: [] },
      #   { opcode: 0x19, mnemonic: 'ADD HL, DE', length: 1, cycles: 8, method: :add_hl_r16, operands: [:de] },
      #   { opcode: 0x1A, mnemonic: 'LD A, (DE)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[a de] },
      #   { opcode: 0x1B, mnemonic: 'DEC DE', length: 1, cycles: 8, method: :dec_r16, operands: [:de] },
      #   { opcode: 0x1C, mnemonic: 'INC E', length: 1, cycles: 4, method: :inc_r8, operands: [:e] },
      #   { opcode: 0x1D, mnemonic: 'DEC E', length: 1, cycles: 4, method: :dec_r8, operands: [:e] },
      #   { opcode: 0x1E, mnemonic: 'LD E, d8', length: 2, cycles: 8, method: :load_r8_d8, operands: [:e] },
      #   { opcode: 0x1F, mnemonic: 'RRA', length: 1, cycles: 4, method: :rra, operands: [] },
      #   { opcode: 0x20, mnemonic: 'JR NZ, r8', length: 2, cycles: [12, 8], method: :jump_relative_cond, operands: [:nz] },
      #   { opcode: 0x21, mnemonic: 'LD HL, d16', length: 3, cycles: 12, method: :load_r16_imm16, operands: [:hl=] },
      #   { opcode: 0x22, mnemonic: 'LD (HL+), A', length: 1, cycles: 8, method: :load_mem_inc_hl, operands: [:a] },
      #   { opcode: 0x23, mnemonic: 'INC HL', length: 1, cycles: 8, method: :inc_r16, operands: [:hl] },
      #   { opcode: 0x24, mnemonic: 'INC H', length: 1, cycles: 4, method: :inc_r8, operands: [:h] },
      #   { opcode: 0x25, mnemonic: 'DEC H', length: 1, cycles: 4, method: :dec_r8, operands: [:h] },
      #   { opcode: 0x26, mnemonic: 'LD H, d8', length: 2, cycles: 8, method: :load_r8_d8, operands: [:h] },
      #   { opcode: 0x27, mnemonic: 'DAA', length: 1, cycles: 4, method: :daa, operands: [] },
      #   { opcode: 0x28, mnemonic: 'JR Z, r8', length: 2, cycles: [12, 8], method: :jump_relative_cond, operands: [:z] },
      #   { opcode: 0x29, mnemonic: 'ADD HL, HL', length: 1, cycles: 8, method: :add_hl_r16, operands: [:hl] },
      #   { opcode: 0x2A, mnemonic: 'LD A, (HL+)', length: 1, cycles: 8, method: :load_r8_mem_inc_hl, operands: [] },
      #   { opcode: 0x2B, mnemonic: 'DEC HL', length: 1, cycles: 8, method: :dec_r16, operands: [:hl] },
      #   { opcode: 0x2C, mnemonic: 'INC L', length: 1, cycles: 4, method: :inc_r8, operands: [:l] },
      #   { opcode: 0x2D, mnemonic: 'DEC L', length: 1, cycles: 4, method: :dec_r8, operands: [:l] },
      #   { opcode: 0x2E, mnemonic: 'LD L, d8', length: 2, cycles: 8, method: :load_r8_d8, operands: [:l] },
      #   { opcode: 0x2F, mnemonic: 'CPL', length: 1, cycles: 4, method: :cpl, operands: [] },
      #   { opcode: 0x30, mnemonic: 'JR NC, r8', length: 2, cycles: [12, 8], method: :jump_relative_cond, operands: [:nc] },
      #   { opcode: 0x31, mnemonic: 'LD SP, d16', length: 3, cycles: 12, method: :load_r16_imm16, operands: [:sp=] },
      #   { opcode: 0x32, mnemonic: 'LD (HL-), A', length: 1, cycles: 8, method: :load_mem_dec_hl, operands: [:a] },
      #   { opcode: 0x33, mnemonic: 'INC SP', length: 1, cycles: 8, method: :inc_r16, operands: [:sp] },
      #   { opcode: 0x34, mnemonic: 'INC (HL)', length: 1, cycles: 12, method: :inc_at_mem_hl, operands: [] },
      #   { opcode: 0x35, mnemonic: 'DEC (HL)', length: 1, cycles: 12, method: :dec_mem_hl, operands: [] },
      #   { opcode: 0x36, mnemonic: 'LD (HL), d8', length: 2, cycles: 12, method: :load_mem_d8, operands: [] },
      #   { opcode: 0x37, mnemonic: 'SCF', length: 1, cycles: 4, method: :scf, operands: [] },
      #   { opcode: 0x38, mnemonic: 'JR C, r8', length: 2, cycles: [12, 8], method: :jump_relative_cond, operands: [:c] },
      #   { opcode: 0x39, mnemonic: 'ADD HL, SP', length: 1, cycles: 8, method: :add_hl_r16, operands: [:sp] },
      #   { opcode: 0x3A, mnemonic: 'LD A, (HL-)', length: 1, cycles: 8, method: :load_r8_mem_dec_hl, operands: [] },
      #   { opcode: 0x3B, mnemonic: 'DEC SP', length: 1, cycles: 8, method: :dec_r16, operands: [:sp] },
      #   { opcode: 0x3C, mnemonic: 'INC A', length: 1, cycles: 4, method: :inc_r8, operands: [:a] },
      #   { opcode: 0x3D, mnemonic: 'DEC A', length: 1, cycles: 4, method: :dec_r8, operands: [:a] },
      #   { opcode: 0x3E, mnemonic: 'LD A, d8', length: 2, cycles: 8, method: :load_r8_d8, operands: [:a] },
      #   { opcode: 0x3F, mnemonic: 'CCF', length: 1, cycles: 4, method: :ccf, operands: [] },
      #   { opcode: 0x40, mnemonic: 'LD B, B', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[b= b] },
      #   { opcode: 0x41, mnemonic: 'LD B, C', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[b= c] },
      #   { opcode: 0x42, mnemonic: 'LD B, D', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[b= d] },
      #   { opcode: 0x43, mnemonic: 'LD B, E', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[b= e] },
      #   { opcode: 0x44, mnemonic: 'LD B, H', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[b= h] },
      #   { opcode: 0x45, mnemonic: 'LD B, L', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[b= l] },
      #   { opcode: 0x46, mnemonic: 'LD B, (HL)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[b hl] },
      #   { opcode: 0x47, mnemonic: 'LD B, A', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[b= a] },
      #   { opcode: 0x48, mnemonic: 'LD C, B', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[c= b] },
      #   { opcode: 0x49, mnemonic: 'LD C, C', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[c= c] },
      #   { opcode: 0x4A, mnemonic: 'LD C, D', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[c= d] },
      #   { opcode: 0x4B, mnemonic: 'LD C, E', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[c= e] },
      #   { opcode: 0x4C, mnemonic: 'LD C, H', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[c= h] },
      #   { opcode: 0x4D, mnemonic: 'LD C, L', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[c= l] },
      #   { opcode: 0x4E, mnemonic: 'LD C, (HL)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[c hl] },
      #   { opcode: 0x4F, mnemonic: 'LD C, A', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[c= a] },
      #   { opcode: 0x50, mnemonic: 'LD D, B', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[d= b] },
      #   { opcode: 0x51, mnemonic: 'LD D, C', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[d= c] },
      #   { opcode: 0x52, mnemonic: 'LD D, D', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[d= d] },
      #   { opcode: 0x53, mnemonic: 'LD D, E', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[d= e] },
      #   { opcode: 0x54, mnemonic: 'LD D, H', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[d= h] },
      #   { opcode: 0x55, mnemonic: 'LD D, L', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[d= l] },
      #   { opcode: 0x56, mnemonic: 'LD D, (HL)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[d hl] },
      #   { opcode: 0x57, mnemonic: 'LD D, A', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[d= a] },
      #   { opcode: 0x58, mnemonic: 'LD E, B', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[e= b] },
      #   { opcode: 0x59, mnemonic: 'LD E, C', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[e= c] },
      #   { opcode: 0x5A, mnemonic: 'LD E, D', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[e= d] },
      #   { opcode: 0x5B, mnemonic: 'LD E, E', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[e= e] },
      #   { opcode: 0x5C, mnemonic: 'LD E, H', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[e= h] },
      #   { opcode: 0x5D, mnemonic: 'LD E, L', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[e= l] },
      #   { opcode: 0x5E, mnemonic: 'LD E, (HL)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[e hl] },
      #   { opcode: 0x5F, mnemonic: 'LD E, A', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[e= a] },
      #   { opcode: 0x60, mnemonic: 'LD H, B', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[h= b] },
      #   { opcode: 0x61, mnemonic: 'LD H, C', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[h= c] },
      #   { opcode: 0x62, mnemonic: 'LD H, D', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[h= d] },
      #   { opcode: 0x63, mnemonic: 'LD H, E', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[h= e] },
      #   { opcode: 0x64, mnemonic: 'LD H, H', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[h= h] },
      #   { opcode: 0x65, mnemonic: 'LD H, L', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[h= l] },
      #   { opcode: 0x66, mnemonic: 'LD H, (HL)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[h hl] },
      #   { opcode: 0x67, mnemonic: 'LD H, A', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[h= a] },
      #   { opcode: 0x68, mnemonic: 'LD L, B', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[l= b] },
      #   { opcode: 0x69, mnemonic: 'LD L, C', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[l= c] },
      #   { opcode: 0x6A, mnemonic: 'LD L, D', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[l= d] },
      #   { opcode: 0x6B, mnemonic: 'LD L, E', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[l= e] },
      #   { opcode: 0x6C, mnemonic: 'LD L, H', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[l= h] },
      #   { opcode: 0x6D, mnemonic: 'LD L, L', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[l= l] },
      #   { opcode: 0x6E, mnemonic: 'LD L, (HL)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[l hl] },
      #   { opcode: 0x6F, mnemonic: 'LD L, A', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[l= a] },
      #   { opcode: 0x70, mnemonic: 'LD (HL), B', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[hl b] },
      #   { opcode: 0x71, mnemonic: 'LD (HL), C', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[hl c] },
      #   { opcode: 0x72, mnemonic: 'LD (HL), D', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[hl d] },
      #   { opcode: 0x73, mnemonic: 'LD (HL), E', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[hl e] },
      #   { opcode: 0x74, mnemonic: 'LD (HL), H', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[hl h] },
      #   { opcode: 0x75, mnemonic: 'LD (HL), L', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[hl l] },
      #   { opcode: 0x76, mnemonic: 'HALT', length: 1, cycles: 4, method: :halt, operands: [] },
      #   { opcode: 0x77, mnemonic: 'LD (HL), A', length: 1, cycles: 8, method: :load_mem_r8, operands: %i[hl a] },
      #   { opcode: 0x78, mnemonic: 'LD A, B', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[a= b] },
      #   { opcode: 0x79, mnemonic: 'LD A, C', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[a= c] },
      #   { opcode: 0x7A, mnemonic: 'LD A, D', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[a= d] },
      #   { opcode: 0x7B, mnemonic: 'LD A, E', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[a= e] },
      #   { opcode: 0x7C, mnemonic: 'LD A, H', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[a= h] },
      #   { opcode: 0x7D, mnemonic: 'LD A, L', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[a= l] },
      #   { opcode: 0x7E, mnemonic: 'LD A, (HL)', length: 1, cycles: 8, method: :load_r8_mem, operands: %i[a hl] },
      #   { opcode: 0x7F, mnemonic: 'LD A, A', length: 1, cycles: 4, method: :load_r8_r8, operands: %i[a= a] },
      #   { opcode: 0x80, mnemonic: 'ADD A, B', length: 1, cycles: 4, method: :add_a_r8, operands: [:b] },
      #   { opcode: 0x81, mnemonic: 'ADD A, C', length: 1, cycles: 4, method: :add_a_r8, operands: [:c] },
      #   { opcode: 0x82, mnemonic: 'ADD A, D', length: 1, cycles: 4, method: :add_a_r8, operands: [:d] },
      #   { opcode: 0x83, mnemonic: 'ADD A, E', length: 1, cycles: 4, method: :add_a_r8, operands: [:e] },
      #   { opcode: 0x84, mnemonic: 'ADD A, H', length: 1, cycles: 4, method: :add_a_r8, operands: [:h] },
      #   { opcode: 0x85, mnemonic: 'ADD A, L', length: 1, cycles: 4, method: :add_a_r8, operands: [:l] },
      #   { opcode: 0x86, mnemonic: 'ADD A, (HL)', length: 1, cycles: 8, method: :add_a_mem_hl, operands: [] },
      #   { opcode: 0x87, mnemonic: 'ADD A, A', length: 1, cycles: 4, method: :add_a_r8, operands: [:a] },
      #   { opcode: 0x88, mnemonic: 'ADC A, B', length: 1, cycles: 4, method: :adc_a_r8, operands: [:b] },
      #   { opcode: 0x89, mnemonic: 'ADC A, C', length: 1, cycles: 4, method: :adc_a_r8, operands: [:c] },
      #   { opcode: 0x8A, mnemonic: 'ADC A, D', length: 1, cycles: 4, method: :adc_a_r8, operands: [:d] },
      #   { opcode: 0x8B, mnemonic: 'ADC A, E', length: 1, cycles: 4, method: :adc_a_r8, operands: [:e] },
      #   { opcode: 0x8C, mnemonic: 'ADC A, H', length: 1, cycles: 4, method: :adc_a_r8, operands: [:h] },
      #   { opcode: 0x8D, mnemonic: 'ADC A, L', length: 1, cycles: 4, method: :adc_a_r8, operands: [:l] },
      #   { opcode: 0x8E, mnemonic: 'ADC A, (HL)', length: 1, cycles: 8, method: :adc_a_mem_hl, operands: [] },
      #   { opcode: 0x8F, mnemonic: 'ADC A, A', length: 1, cycles: 4, method: :adc_a_r8, operands: [:a] },
      #   { opcode: 0x90, mnemonic: 'SUB B', length: 1, cycles: 4, method: :sub_r8, operands: [:b] },
      #   { opcode: 0x91, mnemonic: 'SUB C', length: 1, cycles: 4, method: :sub_r8, operands: [:c] },
      #   { opcode: 0x92, mnemonic: 'SUB D', length: 1, cycles: 4, method: :sub_r8, operands: [:d] },
      #   { opcode: 0x93, mnemonic: 'SUB E', length: 1, cycles: 4, method: :sub_r8, operands: [:e] },
      #   { opcode: 0x94, mnemonic: 'SUB H', length: 1, cycles: 4, method: :sub_r8, operands: [:h] },
      #   { opcode: 0x95, mnemonic: 'SUB L', length: 1, cycles: 4, method: :sub_r8, operands: [:l] },
      #   { opcode: 0x96, mnemonic: 'SUB (HL)', length: 1, cycles: 8, method: :sub_mem_hl, operands: [] },
      #   { opcode: 0x97, mnemonic: 'SUB A', length: 1, cycles: 4, method: :sub_r8, operands: [:a] },
      #   { opcode: 0x98, mnemonic: 'SBC A, B', length: 1, cycles: 4, method: :sbc_a_r8, operands: [:b] },
      #   { opcode: 0x99, mnemonic: 'SBC A, C', length: 1, cycles: 4, method: :sbc_a_r8, operands: [:c] },
      #   { opcode: 0x9A, mnemonic: 'SBC A, D', length: 1, cycles: 4, method: :sbc_a_r8, operands: [:d] },
      #   { opcode: 0x9B, mnemonic: 'SBC A, E', length: 1, cycles: 4, method: :sbc_a_r8, operands: [:e] },
      #   { opcode: 0x9C, mnemonic: 'SBC A, H', length: 1, cycles: 4, method: :sbc_a_r8, operands: [:h] },
      #   { opcode: 0x9D, mnemonic: 'SBC A, L', length: 1, cycles: 4, method: :sbc_a_r8, operands: [:l] },
      #   { opcode: 0x9E, mnemonic: 'SBC A, (HL)', length: 1, cycles: 8, method: :sbc_a_mem_hl, operands: [] },
      #   { opcode: 0x9F, mnemonic: 'SBC A, A', length: 1, cycles: 4, method: :sbc_a_r8, operands: [:a] },
      #   { opcode: 0xA0, mnemonic: 'AND B', length: 1, cycles: 4, method: :and_r8, operands: [:b] },
      #   { opcode: 0xA1, mnemonic: 'AND C', length: 1, cycles: 4, method: :and_r8, operands: [:c] },
      #   { opcode: 0xA2, mnemonic: 'AND D', length: 1, cycles: 4, method: :and_r8, operands: [:d] },
      #   { opcode: 0xA3, mnemonic: 'AND E', length: 1, cycles: 4, method: :and_r8, operands: [:e] },
      #   { opcode: 0xA4, mnemonic: 'AND H', length: 1, cycles: 4, method: :and_r8, operands: [:h] },
      #   { opcode: 0xA5, mnemonic: 'AND L', length: 1, cycles: 4, method: :and_r8, operands: [:l] },
      #   { opcode: 0xA6, mnemonic: 'AND (HL)', length: 1, cycles: 8, method: :and_mem_hl, operands: [] },
      #   { opcode: 0xA7, mnemonic: 'AND A', length: 1, cycles: 4, method: :and_r8, operands: [:a] },
      #   { opcode: 0xA8, mnemonic: 'XOR B', length: 1, cycles: 4, method: :xor_r, operands: [:b] },
      #   { opcode: 0xA9, mnemonic: 'XOR C', length: 1, cycles: 4, method: :xor_r, operands: [:c] },
      #   { opcode: 0xAA, mnemonic: 'XOR D', length: 1, cycles: 4, method: :xor_r, operands: [:d] },
      #   { opcode: 0xAB, mnemonic: 'XOR E', length: 1, cycles: 4, method: :xor_r, operands: [:e] },
      #   { opcode: 0xAC, mnemonic: 'XOR H', length: 1, cycles: 4, method: :xor_r, operands: [:h] },
      #   { opcode: 0xAD, mnemonic: 'XOR L', length: 1, cycles: 4, method: :xor_r, operands: [:l] },
      #   { opcode: 0xAE, mnemonic: 'XOR (HL)', length: 1, cycles: 8, method: :xor_mem_hl, operands: [] },
      #   { opcode: 0xAF, mnemonic: 'XOR A', length: 1, cycles: 4, method: :xor_r, operands: [:a] },
      #   { opcode: 0xB0, mnemonic: 'OR B', length: 1, cycles: 4, method: :or_r8, operands: [:b] },
      #   { opcode: 0xB1, mnemonic: 'OR C', length: 1, cycles: 4, method: :or_r8, operands: [:c] },
      #   { opcode: 0xB2, mnemonic: 'OR D', length: 1, cycles: 4, method: :or_r8, operands: [:d] },
      #   { opcode: 0xB3, mnemonic: 'OR E', length: 1, cycles: 4, method: :or_r8, operands: [:e] },
      #   { opcode: 0xB4, mnemonic: 'OR H', length: 1, cycles: 4, method: :or_r8, operands: [:h] },
      #   { opcode: 0xB5, mnemonic: 'OR L', length: 1, cycles: 4, method: :or_r8, operands: [:l] },
      #   { opcode: 0xB6, mnemonic: 'OR (HL)', length: 1, cycles: 8, method: :or_mem_hl, operands: [] },
      #   { opcode: 0xB7, mnemonic: 'OR A', length: 1, cycles: 4, method: :or_r8, operands: [:a] },
      #   { opcode: 0xB8, mnemonic: 'CP B', length: 1, cycles: 4, method: :cp_r8, operands: [:b] },
      #   { opcode: 0xB9, mnemonic: 'CP C', length: 1, cycles: 4, method: :cp_r8, operands: [:c] },
      #   { opcode: 0xBA, mnemonic: 'CP D', length: 1, cycles: 4, method: :cp_r8, operands: [:d] },
      #   { opcode: 0xBB, mnemonic: 'CP E', length: 1, cycles: 4, method: :cp_r8, operands: [:e] },
      #   { opcode: 0xBC, mnemonic: 'CP H', length: 1, cycles: 4, method: :cp_r8, operands: [:h] },
      #   { opcode: 0xBD, mnemonic: 'CP L', length: 1, cycles: 4, method: :cp_r8, operands: [:l] },
      #   { opcode: 0xBE, mnemonic: 'CP (HL)', length: 1, cycles: 8, method: :cp_mem_hl, operands: [] },
      #   { opcode: 0xBF, mnemonic: 'CP A', length: 1, cycles: 4, method: :cp_r8, operands: [:a] },
      #   { opcode: 0xC0, mnemonic: 'RET NZ', length: 1, cycles: [20, 8], method: :ret_cond, operands: [:nz] },
      #   { opcode: 0xC1, mnemonic: 'POP BC', length: 1, cycles: 12, method: :pop_r16, operands: [:bc=] },
      #   { opcode: 0xC2, mnemonic: 'JP NZ, a16', length: 3, cycles: [16, 12], method: :jump_cond_a16, operands: [:nz] },
      #   { opcode: 0xC3, mnemonic: 'JP a16', length: 3, cycles: 16, method: :jump_a16, operands: [] },
      #   { opcode: 0xC4, mnemonic: 'CALL NZ, a16', length: 3, cycles: [24, 12], method: :call_cond_a16, operands: [:nz] },
      #   { opcode: 0xC5, mnemonic: 'PUSH BC', length: 1, cycles: 16, method: :push_r16, operands: [:bc] },
      #   { opcode: 0xC6, mnemonic: 'ADD A, d8', length: 2, cycles: 8, method: :add_a_d8, operands: [] },
      #   { opcode: 0xC7, mnemonic: 'RST 00H', length: 1, cycles: 16, method: :rst, operands: [0x00] },
      #   { opcode: 0xC8, mnemonic: 'RET Z', length: 1, cycles: [20, 8], method: :ret_cond, operands: [:z] },
      #   { opcode: 0xC9, mnemonic: 'RET', length: 1, cycles: 16, method: :ret, operands: [] },
      #   { opcode: 0xCA, mnemonic: 'JP Z, a16', length: 3, cycles: [16, 12], method: :jump_cond_a16, operands: [:z] },
      #   { opcode: 0xCB, mnemonic: 'PREFIX', length: 1, cycles: 4, method: :prefix, operands: [] },
      #   { opcode: 0xCC, mnemonic: 'CALL Z, a16', length: 3, cycles: [24, 12], method: :call_cond_a16, operands: [:z] },
      #   { opcode: 0xCD, mnemonic: 'CALL a16', length: 3, cycles: 24, method: :call_a16, operands: [] },
      #   { opcode: 0xCE, mnemonic: 'ADC A, d8', length: 2, cycles: 8, method: :adc_a_d8, operands: [] },
      #   { opcode: 0xCF, mnemonic: 'RST 08H', length: 1, cycles: 16, method: :rst, operands: [0x08] },
      #   { opcode: 0xD0, mnemonic: 'RET NC', length: 1, cycles: [20, 8], method: :ret_cond, operands: [:nc] },
      #   { opcode: 0xD1, mnemonic: 'POP DE', length: 1, cycles: 12, method: :pop_r16, operands: [:de] },
      #   { opcode: 0xD2, mnemonic: 'JP NC, a16', length: 3, cycles: [16, 12], method: :jump_cond_a16, operands: [:nc] },
      #   { opcode: 0xD3, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xD4, mnemonic: 'CALL NC, a16', length: 3, cycles: [24, 12], method: :call_cond_a16, operands: [:nc] },
      #   { opcode: 0xD5, mnemonic: 'PUSH DE', length: 1, cycles: 16, method: :push_r16, operands: [:de] },
      #   { opcode: 0xD6, mnemonic: 'SUB d8', length: 2, cycles: 8, method: :sub_d8, operands: [] },
      #   { opcode: 0xD7, mnemonic: 'RST 10H', length: 1, cycles: 16, method: :rst, operands: [0x10] },
      #   { opcode: 0xD8, mnemonic: 'RET C', length: 1, cycles: [20, 8], method: :ret_cond, operands: [:c] },
      #   { opcode: 0xD9, mnemonic: 'RETI', length: 1, cycles: 16, method: :reti, operands: [] },
      #   { opcode: 0xDA, mnemonic: 'JP C, a16', length: 3, cycles: [16, 12], method: :jump_cond_a16, operands: [:c] },
      #   { opcode: 0xDB, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xDC, mnemonic: 'CALL C, a16', length: 3, cycles: [24, 12], method: :call_cond_a16, operands: [:c] },
      #   { opcode: 0xDD, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xDE, mnemonic: 'SBC A, d8', length: 2, cycles: 8, method: :sbc_a_d8, operands: [] },
      #   { opcode: 0xDF, mnemonic: 'RST 18H', length: 1, cycles: 16, method: :rst, operands: [0x18] },
      #   { opcode: 0xE0, mnemonic: 'LDH (a8), A', length: 2, cycles: 12, method: :load_high_mem_a, operands: [] },
      #   { opcode: 0xE1, mnemonic: 'POP HL', length: 1, cycles: 12, method: :pop_r16, operands: [:hl] },
      #   { opcode: 0xE2, mnemonic: 'LD (C), A', length: 1, cycles: 8, method: :load_high_mem_c_a, operands: [] },
      #   { opcode: 0xE3, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xE4, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xE5, mnemonic: 'PUSH HL', length: 1, cycles: 16, method: :push_r16, operands: [:hl] },
      #   { opcode: 0xE6, mnemonic: 'AND d8', length: 2, cycles: 8, method: :and_d8, operands: [] },
      #   { opcode: 0xE7, mnemonic: 'RST 20H', length: 1, cycles: 16, method: :rst, operands: [0x20] },
      #   { opcode: 0xE8, mnemonic: 'ADD SP, r8', length: 2, cycles: 16, method: :add_sp_r8, operands: [] },
      #   { opcode: 0xE9, mnemonic: 'JP HL', length: 1, cycles: 4, method: :jump_hl, operands: [] },
      #   { opcode: 0xEA, mnemonic: 'LD (a16), A', length: 3, cycles: 16, method: :load_mem_a16_a, operands: [] },
      #   { opcode: 0xEB, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xEC, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xED, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xEE, mnemonic: 'XOR d8', length: 2, cycles: 8, method: :xor_d8, operands: [] },
      #   { opcode: 0xEF, mnemonic: 'RST 28H', length: 1, cycles: 16, method: :rst, operands: [0x28] },
      #   { opcode: 0xF0, mnemonic: 'LDH A, (a8)', length: 2, cycles: 12, method: :load_a_high_mem, operands: [] },
      #   { opcode: 0xF1, mnemonic: 'POP AF', length: 1, cycles: 12, method: :pop_r16, operands: [:af] },
      #   { opcode: 0xF2, mnemonic: 'LD A, (C)', length: 1, cycles: 8, method: :load_a_high_mem_c, operands: [] },
      #   { opcode: 0xF3, mnemonic: 'DI', length: 1, cycles: 4, method: :di, operands: [] },
      #   { opcode: 0xF4, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xF5, mnemonic: 'PUSH AF', length: 1, cycles: 16, method: :push_r16, operands: [:af] },
      #   { opcode: 0xF6, mnemonic: 'OR d8', length: 2, cycles: 8, method: :or_d8, operands: [] },
      #   { opcode: 0xF7, mnemonic: 'RST 30H', length: 1, cycles: 16, method: :rst, operands: [0x30] },
      #   { opcode: 0xF8, mnemonic: 'LD HL, SP+r8', length: 2, cycles: 12, method: :load_hl_sp_r8, operands: [] },
      #   { opcode: 0xF9, mnemonic: 'LD SP, HL', length: 1, cycles: 8, method: :load_sp_hl, operands: [] },
      #   { opcode: 0xFA, mnemonic: 'LD A, (a16)', length: 3, cycles: 16, method: :load_a_mem_a16, operands: [] },
      #   { opcode: 0xFB, mnemonic: 'EI', length: 1, cycles: 4, method: :ei, operands: [] },
      #   { opcode: 0xFC, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xFD, mnemonic: 'UNUSED', length: 0, cycles: 0, method: :unused, operands: [] },
      #   { opcode: 0xFE, mnemonic: 'CP d8', length: 2, cycles: 8, method: :cp_d8, operands: [] },
      #   { opcode: 0xFF, mnemonic: 'RST 38H', length: 1, cycles: 16, method: :rst, operands: [0x38] }
      # ].freeze
    end
  end
end

# rubocop:enable Metrics/ModuleLength
