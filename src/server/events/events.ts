onNet('nrm-peek:client:server:foundEntity', async (entity: number) =>
{

    const pNetId = global.source;
    
    try
    {
        const _entity: any = await global.exports["nrm-lib"].findEntity(NetworkGetEntityFromNetworkId(entity));

        if (_entity)
        {
            emitNet('nrm-peek:server:client:triggerEvent', pNetId, JSON.stringify(_entity.getEntries()), entity);
        }
    }
    catch(e)
    {
        //console.log(e)
    }
});