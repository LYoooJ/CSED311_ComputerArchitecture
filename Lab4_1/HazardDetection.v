  HazardDetection HazardDetection(
    .input_1(IF_ID_inst[19:15]),
    .input_2(IF_ID_inst[24:20]),
    .input_3(ID_EX_mem_read),

    .output_1(PCwrite),
    .output_2(IFIDwrite),
    .output_3(hazardout)
  )
  