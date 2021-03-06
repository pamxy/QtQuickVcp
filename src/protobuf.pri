#
# Qt qmake integration with Google Protocol Buffers compiler protoc
#
# To compile protocol buffers with qt qmake, specify PROTOS variable and
# include this file
#
# Example:
# LIBS += /usr/local/lib/libprotobuf.so
# PROTOS = a.proto b.proto
# include(protobuf.pri)
#
# By default protoc looks for .proto files (including the imported ones) in
# the current directory where protoc is run. If you need to include additional
# paths specify the PROTOPATH variable    

isEmpty(PROTOBUF_PROTOC): PROTOBUF_PROTOC = protoc

isEmpty(PROTOGEN): PROTOGEN = generated

!isEmpty(PROTOBUF_INCLUDE_PATH): PROTOPATH += $$PROTOBUF_INCLUDE_PATH
PROTOPATHS =
for(p, PROTOPATH):PROTOPATHS += --proto_path=$$shell_path($$relative_path($${p}, $$OUT_PWD))

message("Generating protocol buffer classes from .proto files.")

protobuf_decl.name = protobuf headers
protobuf_decl.input = PROTOS
protobuf_decl.output = $$OUT_PWD/$$PROTOGEN/$$NAMESPACE_DIR/${QMAKE_FILE_BASE}.pb.h
protobuf_decl.commands = $$shell_path($$PROTOBUF_PROTOC) --cpp_out=$$shell_path($$OUT_PWD/$$PROTOGEN/) $$PROTOPATHS $$relative_path(${QMAKE_FILE_NAME}, $$OUT_PWD)
ios: {
    protobuf_decl.commands += $$escape_expand(\n\t)
    protobuf_decl.commands += sed -i \'\' -e \'s/namespace\ google /namespace\ google_public /g\' ${QMAKE_FILE_OUT} $$escape_expand(\n\t)
    protobuf_decl.commands += sed -i \'\' -e \'s/google::protobuf/google_public::protobuf/g\' ${QMAKE_FILE_OUT}
}
protobuf_decl.variable_out = HEADERS
QMAKE_EXTRA_COMPILERS += protobuf_decl

protobuf_impl.name = protobuf sources
protobuf_impl.input = PROTOS
protobuf_impl.output = $$OUT_PWD/$$PROTOGEN/$$NAMESPACE_DIR/${QMAKE_FILE_BASE}.pb.cc
protobuf_impl.depends = $$OUT_PWD/$$PROTOGEN/$$NAMESPACE_DIR/${QMAKE_FILE_BASE}.pb.h
ios: {
    protobuf_impl.commands += sed -i \'\' -e \'s/namespace\ google /namespace\ google_public /g\' ${QMAKE_FILE_OUT} $$escape_expand(\n\t)
    protobuf_impl.commands += sed -i \'\' -e \'s/google::protobuf/google_public::protobuf/g\' ${QMAKE_FILE_OUT}
}
else {
    protobuf_impl.commands = $$escape_expand(\n)
}
protobuf_impl.variable_out = SOURCES
QMAKE_EXTRA_COMPILERS += protobuf_impl

INCLUDEPATH += $$OUT_PWD/$$PROTOGEN

!isEmpty(PROTOBUF_INCLUDE_PATH): INCLUDEPATH += $$PROTOBUF_INCLUDE_PATH
!isEmpty(PROTOBUF_LIB_PATH): LIBS += -L$$PROTOBUF_LIB_PATH
!isEmpty(PROTOBUF_LIB_FLAGS): LIBS += $$PROTOBUF_LIB_FLAGS

!win32: LIBS += -lprotobuf
win32:  LIBS += -llibprotobuf
