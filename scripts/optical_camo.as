// optical_camo.as — entry QuickMatch script + runtime behavior

#include "path://media/packages/vanilla/scripts"

void main(dictionary@ inputData)
{
    UserSettings settings;
    XmlElement input(inputData);
    settings.fromXmlElement(input);

    QuickMatch metagame(settings);
    metagame.init();
    metagame.run();
    metagame.uninit();
}

// Extend QuickMatch to inject our behavior
class QuickMatch : GameMode
{
    QuickMatch(UserSettings@ settings) { super(settings.m_startServerCommand); }

    override void postBeginMatch()
    {
        GameMode::postBeginMatch();
        startOpticalCamoLogic();
    }

    void startOpticalCamoLogic()
    {
        // Register repeated callback each 0.1s
        addPeriodicTask(0.1, OpticalCamoHandler);
    }

    void OpticalCamoHandler()
    {
        Soldier@ player = getPlayer(0);
        if (player is null) return;

        if (!player.HasCarryItem("optical_camo.carry_item"))
            player.GiveCarryItem("optical_camo.carry_item");

        if (!player.IsWearing("optical_camo.carry_item"))
            return;

        Vec3 pos = player.Position();
        bool crouch = player.IsCrouching();
        bool prone = player.IsProne();

        if (crouch && !prone)
        {
            if (Time() % 1.0 < 0.5)
                spawnInvisibleSandbag(pos, 0.5);
        }
        else if (prone)
        {
            spawnInvisibleSandbag(pos, 1.0);
        }

        if (crouch || prone)
            SpawnParticleEffect("smoke", pos, 1.0);
    }

    void spawnInvisibleSandbag(Vec3 pos, float lifetime)
    {
        // Using metagame create_instance command as per Wiki remote_control interface
        string cmd = "<command class='create_instance' type='map_object' key='sandbag' x='" +
                     pos.x + "' y='" + pos.y + "' z='" + pos.z + "' />";
        getComms().send(cmd);

        // Post-process the created object after slight delay (to fetch instance)
        addDelayedTask(0.01, pos, lifetime);
    }

    void addDelayedTask(float delay, Vec3 pos, float lifetime)
    {
        // This runs after delay to fetch mapobject at pos and adjust its properties
        addPeriodicTaskOnce(delay, (Ref@ args) {
            MapObject@ mobj = getMapObjectAtPos("sandbag", args.pos);
            if (mobj !is null)
            {
                mobj.NoPhysics(true);
                mobj.Visible(false);
                mobj.SetLifetime(args.lifetime);
            }
        });
    }
}
