onNet('nrm-peek:client:server:foundEntity', async (ped: number) =>
{

    const pNetId = global.source;
    
    try
    {
        const event: any = await global.exports["nrm-lib"].findPed(NetworkGetEntityFromNetworkId(ped));
    
        if (event)
        {
            emitNet('nrm-peek:server:client:triggerEvent', pNetId, event.getEvent());
        }
    }
    catch(e)
    {
        console.log(e)
    }
});