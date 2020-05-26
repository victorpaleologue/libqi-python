include_guard(GLOBAL)

set(QIPYTHON_PYTHON_MODULE_NAME qi)
set(QIPYTHON_PYTHON_MODULE_SOURCE_DIR
    ${CMAKE_CURRENT_SOURCE_DIR}/${QIPYTHON_PYTHON_MODULE_NAME})


add_library(qi_python_objects OBJECT)

target_sources(qi_python_objects
  PUBLIC
    qipython/common.hpp
    qipython/pyapplication.hpp
    qipython/pyasync.hpp
    qipython/pyclock.hpp
    qipython/pyexport.hpp
    qipython/pyfuture.hpp
    qipython/pylog.hpp
    qipython/pymodule.hpp
    qipython/pyobject.hpp
    qipython/pypath.hpp
    qipython/pyproperty.hpp
    qipython/pysession.hpp
    qipython/pysignal.hpp
    qipython/pyguard.hpp
    qipython/pytranslator.hpp
    qipython/pytypes.hpp
    qipython/pystrand.hpp

  PRIVATE
    src/pyapplication.cpp
    src/pyasync.cpp
    src/pyclock.cpp
    src/pyexport.cpp
    src/pyfuture.cpp
    src/pylog.cpp
    src/pymodule.cpp
    src/pyobject.cpp
    src/pypath.cpp
    src/pyproperty.cpp
    src/pysession.cpp
    src/pysignal.cpp
    src/pystrand.cpp
    src/pytranslator.cpp
    src/pytypes.cpp
)

enable_warnings(qi_python_objects)

target_include_directories(qi_python_objects PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(qi_python_objects
  PUBLIC pybind11
         qi.interface)

set_target_properties(qi_python_objects
  # Use PIC as the library is linked into a shared library in the qi_python
  # target.
  PROPERTIES POSITION_INDEPENDENT_CODE TRUE)


Python_add_library(qi_python MODULE)

set(QIPYTHON_PYTHON_MODULE_FILES
    qi/__init__.py
    qi/logging.py
    qi/path.py
    qi/translator.py
    qi/_binder.py
    qi/_type.py
    qi/_version.py)

target_sources(qi_python
  PRIVATE src/module.cpp
          ${QIPYTHON_PYTHON_MODULE_FILES}
          qi/test/__init__.py
          qi/test/conftest.py
          qi/test/test_applicationsession.py
          qi/test/test_async.py
          qi/test/test_call.py
          qi/test/test_log.py
          qi/test/test_module.py
          qi/test/test_promise.py
          qi/test/test_property.py
          qi/test/test_return_empty_object.py
          qi/test/test_session.py
          qi/test/test_signal.py
          qi/test/test_strand.py
          qi/test/test_typespassing.py
          setup.py
          pyproject.toml
          README.rst)

enable_warnings(qi_python)

target_link_libraries(qi_python PRIVATE qi_python_objects)

set_target_properties(qi_python
  PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${QIPYTHON_PYTHON_MODULE_NAME}
             RUNTIME_OUTPUT_DIRECTORY ${QIPYTHON_PYTHON_MODULE_NAME})

# Add all the dependencies directories as RPATH for binaries in the build
# directory, so that we may execute them directly.
set(QIPYTHON_BUILD_DEPENDENCIES_LIBRARY_DIRS ${Boost_LIBRARY_DIRS})
foreach(_lib IN LISTS OPENSSL_LIBRARIES ICU_LIBRARIES)
  if(EXISTS ${_lib})
    get_filename_component(_dir ${_lib} DIRECTORY)
    list(APPEND QIPYTHON_BUILD_DEPENDENCIES_LIBRARY_DIRS ${_dir})
  endif()
endforeach()
list(REMOVE_DUPLICATES QIPYTHON_BUILD_DEPENDENCIES_LIBRARY_DIRS)
message(VERBOSE
        "Setting qi_python build RPATH to '${QIPYTHON_BUILD_DEPENDENCIES_LIBRARY_DIRS}'")
set_property(TARGET qi_python PROPERTY
  BUILD_RPATH ${QIPYTHON_BUILD_DEPENDENCIES_LIBRARY_DIRS})

if(NOT QIPYTHON_STANDALONE)
  add_library(qimodule_python_plugin SHARED)
  target_sources(qimodule_python_plugin PRIVATE src/qimodule_python_plugin.cpp)
  target_link_libraries(qimodule_python_plugin PRIVATE qi.interface)
endif()
