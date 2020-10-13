import Private

import XMonad
import XMonad.Util.EZConfig
import qualified XMonad.StackSet as W

import XMonad.Actions.PerWorkspaceKeys
import XMonad.Hooks.ManageDocks
import qualified XMonad.Layout.Groups as G
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.WindowNavigation

modm = mod1Mask

myFullBase   = Full
myTallBase   = Tall 1 (3/100) (1/2)

myFull      = noBorders $ myFullBase
myTiledTabs = windowNavigation $ smartBorders $ G.group myTallBase Full

mainWS = "main"

-- Purposefully leave 'avoidStruts' out.
-- I do want pannels to be shown only at empty workspaces.
--
myLayoutHook = onWorkspace mainWS myTiledTabs myFull

main = xmonad $
    docks $
    defaultConfig {
        borderWidth = 1,
        focusedBorderColor = "#2020c0",
        normalBorderColor = "#202020",
        terminal = termEmulator,
        workspaces = ["web", mainWS, "media", "etc", "5", "6", "7", "8", "9", "0"],
        layoutHook = myLayoutHook,
        focusFollowsMouse = False,
        modMask = modm
        }
    `additionalKeys` [
        -- basic
        ((modm, xK_q), kill),

        -- volume
        ((modm, xK_F1), spawn volToggleMuteCmd),
        ((modm, xK_F2), spawn volDownCmd),
        ((modm, xK_F3), spawn volUpCmd),

        -- navigate with Alt+Tab and Alt+Shift+Tab.
        -- Works in all workspaces.
        --
        ((modm, xK_Tab),                windows W.focusUp),
        ((modm .|. shiftMask, xK_Tab),  windows W.focusDown),

        -- navigate / move windows vertically.
        -- In mainWS, switch between groups;
        -- in all others, just do focusUp / focusDown
        --
        ((modm, xK_j), bindOn [
            (mainWS, sendMessage $ G.Modify G.focusGroupUp),
            ("", windows W.focusUp)
            ]),
        ((modm, xK_k), bindOn [
            (mainWS, sendMessage $ G.Modify G.focusGroupDown),
            ("", windows W.focusDown)
            ]),
        --
        -- same, but for moving.
        -- This only makes sense in mainWS.
        ((modm .|. shiftMask, xK_j), bindOn [(mainWS, sendMessage $ G.Modify $ G.moveToGroupUp False)]),
        ((modm .|. shiftMask, xK_k), bindOn [(mainWS, sendMessage $ G.Modify $ G.moveToGroupDown False)]),

        -- navigate / move windows horizontally.
        -- All of this only makes sense in mainWS.
        ((modm, xK_h),                  bindOn [(mainWS, sendMessage $ G.Modify G.focusMaster)]),
        ((modm, xK_l),                  bindOn [(mainWS, sendMessage $ G.Modify G.focusDown)]),
        ((modm .|. shiftMask, xK_h),    bindOn [(mainWS, sendMessage $ G.Modify G.swapMaster)]),
        ((modm .|. shiftMask, xK_l),    bindOn [(mainWS, sendMessage $ G.Modify G.swapDown)]),

        -- launchers
        ((modm, xK_r),        spawn menuLauncher),
        ((modm, xK_w),        spawn webBrowser),
        ((modm, xK_Return),   spawn termEmulator),

        -- last but not least...
        ((mod1Mask .|. controlMask, xK_Delete), spawn shutdownCmd)
        ]
