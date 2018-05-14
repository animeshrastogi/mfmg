# Helper function
FUNCTION(TARGET_INCLUDE_AND_LINK TEST_NAME)
  TARGET_INCLUDE_DIRECTORIES(${TEST_NAME} SYSTEM PUBLIC ${MPI_CXX_INCLUDE_PATH})
  TARGET_LINK_LIBRARIES(${TEST_NAME} PUBLIC ${MPI_CXX_LIBRARIES})
  TARGET_INCLUDE_DIRECTORIES(${TEST_NAME} SYSTEM PUBLIC ${Boost_INCLUDE_DIRS})
  TARGET_LINK_LIBRARIES(${TEST_NAME} PUBLIC ${Boost_LIBRARIES})
  TARGET_INCLUDE_DIRECTORIES(${TEST_NAME} SYSTEM PUBLIC ${DEAL_II_INCLUDE_DIRS})
  TARGET_LINK_LIBRARIES(${TEST_NAME} PUBLIC ${DEAL_II_LIBRARIES})
  TARGET_INCLUDE_DIRECTORIES(${TEST_NAME} SYSTEM PUBLIC ${CMAKE_SOURCE_DIR}/include)
  TARGET_LINK_LIBRARIES(${TEST_NAME} PUBLIC mfmg)
  TARGET_LINK_LIBRARIES(${TEST_NAME} PUBLIC ${MFMG_CUDA_LIBRARIES})
  TARGET_INCLUDE_DIRECTORIES(${TEST_NAME} PUBLIC ${AMGX_INCLUDE_DIR})
  TARGET_LINK_LIBRARIES(${TEST_NAME} PUBLIC ${AMGX_LIBRARY})
ENDFUNCTION()

# Helper function
FUNCTION(RUN_PROPERTIES TEST_NAME)
  FOREACH(NPROC ${NUMBER_OF_PROCESSES_TO_EXECUTE})
    ADD_TEST(
      NAME ${TEST_NAME}_${NPROC}
      COMMAND ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} ${NPROC} ./${TEST_NAME}
      )
    SET_TESTS_PROPERTIES(${TEST_NAME}_${NPROC} PROPERTIES
      PROCESSORS ${NPROC}
      )
  ENDFOREACH()
ENDFUNCTION()

# Add a C++ test
FUNCTION(MFMG_ADD_TEST TEST_NAME)
  ADD_EXECUTABLE(${TEST_NAME} ${CMAKE_CURRENT_SOURCE_DIR}/${TEST_NAME}.cc ${TESTS_SOURCES})
  TARGET_INCLUDE_AND_LINK(${TEST_NAME})

  SET_TARGET_PROPERTIES(${TEST_NAME} PROPERTIES
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    )

  IF(ARGN)
    SET(NUMBER_OF_PROCESSES_TO_EXECUTE ${ARGN})
  ELSE()
    SET(NUMBER_OF_PROCESSES_TO_EXECUTE 1)
  ENDIF()
  RUN_PROPERTIES(${TEST_NAME})
ENDFUNCTION()

# Add a CUDA test
FUNCTION(MFMG_ADD_CUDA_TEST TEST_NAME)
  ADD_EXECUTABLE(${TEST_NAME} ${CMAKE_CURRENT_SOURCE_DIR}/${TEST_NAME}.cu ${TESTS_SOURCES})
  TARGET_INCLUDE_AND_LINK(${TEST_NAME})

  SET_TARGET_PROPERTIES(${TEST_NAME} PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
    CUDA_STANDARD 11
    CUDA_STANDARD_REQUIRED ON
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    )

  IF(ARGN)
    SET(NUMBER_OF_PROCESSES_TO_EXECUTE ${ARGN})
  ELSE()
    SET(NUMBER_OF_PROCESSES_TO_EXECUTE 1)
  ENDIF()
  RUN_PROPERTIES(${TEST_NAME})
ENDFUNCTION()

# Copy input files
FUNCTION(MFMG_COPY_INPUT_FILE INPUT_FILE PATH_TO_FILE)
  ADD_CUSTOM_COMMAND(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${INPUT_FILE}
    DEPENDS ${CMAKE_SOURCE_DIR}/${PATH_TO_FILE}/${INPUT_FILE}
    COMMAND ${CMAKE_COMMAND}
    ARGS -E copy ${CMAKE_SOURCE_DIR}/${PATH_TO_FILE}/${INPUT_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${INPUT_FILE}
    COMMENT "Copying ${INPUT_FILE}"
    )

  STRING(REGEX REPLACE "/" "_" DUMMY ${CMAKE_CURRENT_BINARY_DIR}/${INPUT_FILE})

  ADD_CUSTOM_TARGET(
    ${DUMMY} ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${INPUT_FILE}
    )
ENDFUNCTION()
