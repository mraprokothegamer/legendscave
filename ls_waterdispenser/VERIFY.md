# Verify v2.4.3

1. Console shows: `[ls_waterdispenser] v2.4.3 loaded`
2. No `client/prop.lua` in the folder
3. Third-eye a water cooler → Drink Water
4. Cup appears, NUI fills ~10s, then hides
5. Thirst goes up ~30%
6. F8 / server console must **not** print `NETWORK_GET_NETWORK_ID_FROM_ENTITY: no net object for entity` while drinking
