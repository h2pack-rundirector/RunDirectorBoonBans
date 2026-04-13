local lu = require("luaunit")

require("tests/TestUtils")

TestUiRoots = {}

function TestUiRoots:setUp()
    self.ui, self.internal, self.state = ResetBoonBansUiHarness()
    self.ui.BuildRootDescriptors()
    self.apollo = self.ui.GetRootById("Apollo")
    self.circe = self.ui.GetRootById("Circe")
end

function TestUiRoots:testBuildRootDescriptorsCreatesTieredViews()
    lu.assertNotNil(self.apollo)
    lu.assertTrue(self.apollo.isTiered)
    lu.assertEquals(#self.apollo.scopes, 3)
    lu.assertEquals(self.apollo.views[1].label, "Force")
    lu.assertEquals(self.apollo.views[2].label, "1st")
    lu.assertEquals(self.apollo.views[3].label, "2nd")
    lu.assertEquals(self.apollo.views[4].label, "3rd")
    lu.assertEquals(self.apollo.views[5].label, "Rarity")
end

function TestUiRoots:testGetRootSummaryLabelUsesChangedTierCount()
    lu.assertEquals(self.ui.GetRootSummaryLabel(self.apollo, {}), "(2/3 tiers changed)")
    lu.assertEquals(self.ui.GetRootSummaryLabel(self.circe, {}), "(1/3 Banned)")
end

function TestUiRoots:testGetRootHeaderSummaryFormatsTierBanCounts()
    lu.assertEquals(
        self.ui.GetRootHeaderSummary(self.apollo, {}),
        "1st:1/5   2nd:0/5   3rd:2/5"
    )
end

function TestUiRoots:testGetCustomizedRootCountCountsEachRootOnce()
    lu.assertEquals(self.ui.GetCustomizedRootCount({}), 2)
end

function TestUiRoots:testApplyForceOneWritesExpectedMaskAndUpdatesStats()
    local changed = self.ui.ApplyForceOne("Apollo", "Cast", {})

    lu.assertTrue(changed)
    lu.assertEquals(self.state.banConfig.Apollo, 23)
    lu.assertEquals(self.internal.godInfo.Apollo.banned, 4)
    lu.assertEquals(self.state.getRecalcCalls(), 0)
end

TestUiViews = {}

function TestUiViews:setUp()
    self.ui, self.internal, self.state = ResetBoonBansUiHarness()
    self.ui.BuildRootDescriptors()
    self.apollo = self.ui.GetRootById("Apollo")
end

function TestUiViews:testBuildRarityRowsExcludesSpecialBoonTypes()
    local rows = self.ui.BuildRarityRows(self.apollo)
    local names = {}
    for _, row in ipairs(rows) do
        table.insert(names, row.name)
    end

    lu.assertEquals(names, { "Strike", "Cast" })
end

