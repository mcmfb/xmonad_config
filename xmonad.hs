import Private

import XMonad
import XMonad.Util.EZConfig
import qualified XMonad.StackSet as W

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import qualified XMonad.Layout.Groups as G
import XMonad.Layout.NoBorders
import XMonad.Layout.WindowNavigation

import Data.Monoid

modm = mod1Mask

myFull = Full
myTall = Tall 1 (3/100) (1/2)
--
-- Purposefully leave 'avoidStruts' out.
-- I do want pannels to be shown only at empty workspaces.
--
myLayoutHook = windowNavigation $ smartBorders $ G.group myTall myFull

-- Put all new windows in a new group below.
placeWindowInNewGroup :: MaybeManageHook
placeWindowInNewGroup = do
    newWindow <- ask
    liftX $ windows (W.insertUp newWindow)
    liftX $ sendMessage $ G.Modify $ G.moveToNewGroupDown
    idHook

myManageHook :: ManageHook
myManageHook = composeOne [
    ((className =? "polybar")
        <||> (className =? "Polybar")
        <||> (className =? "Dialog")
        <||> (className =? "DialogWindow")) -?> idHook,
    placeWindowInNewGroup
    ]

myWorkspaces :: [String]
myWorkspaces = ["web", "main", "media", "etc" ] ++ (map show [5..10])

main = xmonad $
    ewmh $
    docks $
    defaultConfig {
        borderWidth = 1,
        focusedBorderColor = "#2020c0",
        normalBorderColor = "#202020",
        terminal = termEmulator,
        workspaces = myWorkspaces,
        layoutHook = myLayoutHook,
        manageHook = myManageHook <+> manageHook def,
        focusFollowsMouse = False,
        modMask = modm
        }
    `additionalKeys` [
        -- window shortcuts
        ((modm, xK_q), kill),

        -- volume
        ((modm, xK_F2), spawn volDownCmd),
        ((modm, xK_F3), spawn volUpCmd),

        -- cycle windows in StackSet, disregarding layout.
        ((modm, xK_Tab),                windows W.focusUp),
        ((modm .|. shiftMask, xK_Tab),  windows W.focusDown),

        -- navigate / move windows vertically, by switching between groups.
        ((modm, xK_j),                  sendMessage $ G.Modify G.focusGroupUp),
        ((modm, xK_k),                  sendMessage $ G.Modify G.focusGroupDown),
        ((modm .|. shiftMask, xK_j),    sendMessage $ G.Modify $ G.moveToGroupUp False),
        ((modm .|. shiftMask, xK_k),    sendMessage $ G.Modify $ G.moveToGroupDown False),

        -- navigate / move windows horizontally.
        ((modm, xK_h),                  sendMessage $ G.Modify G.focusMaster),
        ((modm, xK_l),                  sendMessage $ G.Modify G.focusDown),
        ((modm .|. shiftMask, xK_h),    sendMessage $ G.Modify G.swapMaster),
        ((modm .|. shiftMask, xK_l),    sendMessage $ G.Modify G.swapDown),

        -- launchers
        ((modm, xK_r),        spawn menuLauncher),
        ((modm, xK_w),        spawn webBrowser),
        ((modm, xK_Return),   spawn termEmulator),

        -- last but not least...
        ((mod1Mask .|. controlMask, xK_Delete), spawn shutdownCmd)
        ]
