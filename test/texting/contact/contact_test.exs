defmodule Texting.ContactTest do
  use Texting.DataCase

  alias Texting.Contact

  describe "phonenumbers" do
    alias Textin.Messenger.Phonenumber

    @valid_attrs %{account_sid: "some account_sid", friendly_name: "some friendly_name", number: "some number", phonenumber_sid: "some phonenumber_sid"}
    @update_attrs %{account_sid: "some updated account_sid", friendly_name: "some updated friendly_name", number: "some updated number", phonenumber_sid: "some updated phonenumber_sid"}
    @invalid_attrs %{account_sid: nil, friendly_name: nil, number: nil, phonenumber_sid: nil}

    def phonenumber_fixture(attrs \\ %{}) do
      {:ok, phonenumber} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contact.create_phonenumber()

      phonenumber
    end

    test "list_phonenumbers/0 returns all phonenumbers" do
      phonenumber = phonenumber_fixture()
      assert Contact.list_phonenumbers() == [phonenumber]
    end

    test "get_phonenumber!/1 returns the phonenumber with given id" do
      phonenumber = phonenumber_fixture()
      assert Contact.get_phonenumber!(phonenumber.id) == phonenumber
    end

    test "create_phonenumber/1 with valid data creates a phonenumber" do
      assert {:ok, %Phonenumber{} = phonenumber} = Contact.create_phonenumber(@valid_attrs)
      assert phonenumber.account_sid == "some account_sid"
      assert phonenumber.friendly_name == "some friendly_name"
      assert phonenumber.number == "some number"
      assert phonenumber.phonenumber_sid == "some phonenumber_sid"
    end

    test "create_phonenumber/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contact.create_phonenumber(@invalid_attrs)
    end

    test "update_phonenumber/2 with valid data updates the phonenumber" do
      phonenumber = phonenumber_fixture()
      assert {:ok, phonenumber} = Contact.update_phonenumber(phonenumber, @update_attrs)
      assert %Phonenumber{} = phonenumber
      assert phonenumber.account_sid == "some updated account_sid"
      assert phonenumber.friendly_name == "some updated friendly_name"
      assert phonenumber.number == "some updated number"
      assert phonenumber.phonenumber_sid == "some updated phonenumber_sid"
    end

    test "update_phonenumber/2 with invalid data returns error changeset" do
      phonenumber = phonenumber_fixture()
      assert {:error, %Ecto.Changeset{}} = Contact.update_phonenumber(phonenumber, @invalid_attrs)
      assert phonenumber == Contact.get_phonenumber!(phonenumber.id)
    end

    test "delete_phonenumber/1 deletes the phonenumber" do
      phonenumber = phonenumber_fixture()
      assert {:ok, %Phonenumber{}} = Contact.delete_phonenumber(phonenumber)
      assert_raise Ecto.NoResultsError, fn -> Contact.get_phonenumber!(phonenumber.id) end
    end

    test "change_phonenumber/1 returns a phonenumber changeset" do
      phonenumber = phonenumber_fixture()
      assert %Ecto.Changeset{} = Contact.change_phonenumber(phonenumber)
    end
  end
end
