include_directories(
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
)

set(OnlineAccountsClientQml_SRC
  plugin.cpp
  MockSetup.cpp
)

add_library(OnlineAccountsClientQml SHARED ${OnlineAccountsClientQml_SRC})
target_link_libraries(OnlineAccountsClientQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
  Qt5::Core Qt5::Quick
)

add_uss_mock(Ubuntu.OnlineAccounts.Client 0.1 Ubuntu/OnlineAccounts/Client
             TARGETS OnlineAccountsClientQml)
