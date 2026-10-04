// Rust 引擎的 C ABI；句柄只在串行队列上访问。
#include <stddef.h>
#include <stdint.h>
typedef struct QJSession QJSession;
QJSession *qj_create(const char *dictionary_path, const char *glossary_path);
char *qj_dispatch(QJSession *session, const char *action, size_t index, uint64_t revision);
void qj_destroy(QJSession *session);
void qj_string_free(char *value);
