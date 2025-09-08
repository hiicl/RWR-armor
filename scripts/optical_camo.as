void OnUpdate(Player@ player)
{

    if (!player.HasCarryItem("optical_camo.carry_item"))
    {
        player.GiveCarryItem("optical_camo.carry_item");
    }


    bool crouch = player.IsCrouching();
    bool prone  = player.IsProne();
    Vec3 pos = player.Position();


    if (crouch && !prone)
    {
        if (Time() % 1.0 < 0.5)
        {
            SpawnInvisibleSandbag(pos, 0.5);
        }
    }


    if (prone)
    {
        SpawnInvisibleSandbag(pos, 1.0);
    }

    SpawnParticleEffect("smoke", pos, 1.0);
}

void SpawnInvisibleSandbag(Vec3 pos, float lifetime)
{
    MapObject@ sandbag = SpawnMapObject("sandbag", pos);
    sandbag.NoPhysics(true);  
    sandbag.Visible(false);     
    sandbag.SetLifetime(lifetime); 
}
