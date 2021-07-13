module Main where

import HalogenUtils
import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect)
import Effect.Console as Console
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)

foreign import executeJavascriptHacks :: Effect Unit

data Action = Initialize

type State =
  { loading :: Boolean
  }


main :: Effect Unit
main = do
  executeJavascriptHacks
  HA.runHalogenAff do
    body <- HA.awaitBody
    runUI component unit body


component :: forall query input output m. MonadAff m => H.Component query input output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval 
      { handleAction = handleAction 
      , initialize = Just Initialize
      }
    }

initialState :: forall input. input -> State
initialState _ = { loading: false }

render :: forall m. State -> H.ComponentHTML Action () m
render state = HH.div
  [ classString "main" ]
  [ renderHeader
  , renderContent
  ]
  where
  renderContent = HH.div
    [ classString "content" ]
    [ HH.iframe [ HP.src "/blog/rop-cs.html" ] ]
  renderHeader = HH.div
    [ classString "header" ]
    [ renderTitle
    , renderControls
    , renderLoadingIcon
    ]
  renderTitle = HH.div
    [ classString "title largeViewport"]
    [ HH.a
      [ HP.href ""
      , HP.target "_blank"
      ]
      [ HH.h1_ [ HH.text "Devblog" ] ]
    ]
  renderLoadingIcon = HH.div 
    [ classString "loadingIcon lds-ellipsis" ]
    if state.loading then [ HH.div_ [], HH.div_ [], HH.div_ [], HH.div_ [] ] else []
  renderControls = HH.div 
    [ classString "controls" ]
    [ HH.a
      [ HP.href ""
      , HP.target "_blank"
      , HP.tabIndex (-1)
      ]
      [ HH.button [ HP.title "Open the about page in a new browser tab" ] [ fontAwesome "fa-info", optionalText " About" ] ]
    ]

handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction action =
  case action of
    Initialize -> pure unit
