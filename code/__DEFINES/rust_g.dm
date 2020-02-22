// rust_g.dm - DM API for rust_g extension library
#define RUST_G "rust_g"

#define rustg_dmi_strip_metadata(fname) call(RUST_G, "dmi_strip_metadata")(fname)
#define rustg_dmi_create_png(fname,width,height,data) call(RUST_G, "dmi_create_png")(fname,width,height,data)

#define rustg_git_revparse(rev) call(RUST_G, "rg_git_revparse")(rev)
#define rustg_git_commit_date(rev) call(RUST_G, "rg_git_commit_date")(rev)

#define rustg_log_write(fname, text) call(RUST_G, "log_write")(fname, text)
/proc/rustg_log_close_all() return call(RUST_G, "log_close_all")()
