FROM scratch

COPY ./wasm/wasmedge_quickjs.wasm.so /wasm
COPY ./nodejs/v8-v7/*.js /

CMD ["/wasm", "v8-v7.js"]
