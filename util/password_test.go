package util

import (
	"testing"

	"github.com/stretchr/testify/require"
	bycript "golang.org/x/crypto/bcrypt"
)

func TestPassword(t *testing.T) {
	password := RandomString(10)

	hashedPassword1, err := HashPassword(password)
	require.NoError(t, err)
	require.NotEmpty(t, hashedPassword1)

	err = CheckPassword(password, hashedPassword1)
	require.NoError(t, err)

	wrongPassword := RandomString(10)
	err = CheckPassword(wrongPassword, hashedPassword1)
	require.EqualError(t, err, bycript.ErrMismatchedHashAndPassword.Error())

	hashedPassword2, err := HashPassword(password)
	require.NoError(t, err)
	require.NotEmpty(t, hashedPassword1)
	require.NotEqual(t, hashedPassword1, hashedPassword2)
}