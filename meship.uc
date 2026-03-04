import * as socket from "socket";

const PORT = 4404;

let s = null;
let bridge = false;

export function setup(config)
{
    if (!config.meship) {
        return;
    }
    if (config.meship.bridge) {
        bridge = true;
    }
    s = socket.create(socket.AF_INET, socket.SOCK_DGRAM, 0);
    s.bind({
        port: PORT
    });
    s.listen();
};

export function shutdown()
{
};

export function handle()
{
    return s;
};

export function recv()
{
    try {
        return json(s.recvmsg(65535).data);
    }
    catch (_) {
        return null;
    }
};

export function send(to, msg, canforward)
{
    // MeshIP bridge traffic should never be forwarded by a receiver
    // and is only ever for the direct recipient.
    if (bridge) {
        msg.hop_limit = 0;
        canforward = false;
    }
    const targets = platform.getTargetsByIdAndNamekey(to, msg.namekey, canforward);
    const data = sprintf("%J", msg);
    for (let i = 0; i < length(targets); i++) {
        const r = s.send(data, 0, {
            address: targets[i].ip,
            port: PORT
        });
        if (r === null) {
            DEBUG0("meship:send error: %s\n", socket.error());
        }
    }
};

export function tick()
{
};

export function process(msg)
{
};
